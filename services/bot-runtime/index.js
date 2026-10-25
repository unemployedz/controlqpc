import express from "express";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import {
  Client,
  Events,
  GatewayIntentBits,
  REST,
  Routes,
  SlashCommandBuilder
} from "discord.js";

const app = express();
const port = Number(process.env.PORT || 3000);
const controlKey = process.env.CONTROLQPC_CONTROL_KEY;
const allowedOrigin = process.env.ALLOWED_ORIGIN || "";

if (!controlKey || controlKey.length < 32) {
  console.error("Missing or weak CONTROLQPC_CONTROL_KEY. Set a random secret of at least 32 characters.");
  process.exit(1);
}

app.disable("x-powered-by");
app.use(helmet());
app.use(express.json({ limit: "16kb" }));
app.use(rateLimit({ windowMs: 60_000, limit: 60, standardHeaders: true, legacyHeaders: false }));

app.use((req, res, next) => {
  const origin = req.get("origin");
  if (origin && allowedOrigin && origin !== allowedOrigin) {
    return res.status(403).json({ error: "Origin not allowed." });
  }
  if (origin && allowedOrigin) res.setHeader("Access-Control-Allow-Origin", allowedOrigin);
  res.setHeader("Vary", "Origin");
  res.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  if (req.method === "OPTIONS") return res.sendStatus(204);
  next();
});

let client = null;
let startedAt = null;
let botName = "Discord Bot";
let safeLogs = [];
let connecting = false;

function addLog(level, message) {
  const entry = { at: new Date().toISOString(), level, message: String(message).slice(0, 240) };
  safeLogs = [...safeLogs, entry].slice(-100);
  console.log(`[${entry.level}] ${entry.message}`);
}

function requireControlKey(req, res, next) {
  const header = req.get("authorization") || "";
  const provided = header.startsWith("Bearer ") ? header.slice(7) : "";
  if (!provided || provided.length !== controlKey.length ||
      !constantTimeEqual(provided, controlKey)) {
    return res.status(401).json({ error: "Unauthorized." });
  }
  next();
}

function constantTimeEqual(a, b) {
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

function statusSnapshot() {
  const ready = Boolean(client?.isReady());
  return {
    running: ready,
    connecting,
    botName: ready ? client.user.username : botName,
    username: ready ? client.user.tag : null,
    applicationId: ready ? client.application.id : null,
    guildCount: ready ? client.guilds.cache.size : 0,
    uptimeSeconds: ready && startedAt ? Math.floor((Date.now() - startedAt) / 1000) : 0
  };
}

app.get("/health", (_req, res) => res.json({ ok: true, service: "controlqpc-bot-runtime" }));

app.get("/api/bot/status", requireControlKey, (_req, res) => {
  res.set("Cache-Control", "no-store");
  res.json(statusSnapshot());
});

app.get("/api/bot/logs", requireControlKey, (_req, res) => {
  res.set("Cache-Control", "no-store");
  res.json({ logs: safeLogs });
});

app.post("/api/bot/start", requireControlKey, async (req, res) => {
  if (client || connecting) return res.status(409).json({ error: "A bot is already running or connecting." });

  const token = typeof req.body?.token === "string" ? req.body.token.trim() : "";
  const requestedName = typeof req.body?.name === "string" ? req.body.name.trim() : "";
  if (!token || token.length > 256) return res.status(400).json({ error: "Enter a valid bot token." });

  botName = requestedName.slice(0, 80) || "Discord Bot";
  connecting = true;
  const candidate = new Client({ intents: [GatewayIntentBits.Guilds] });
  client = candidate;

  candidate.once(Events.ClientReady, async (readyClient) => {
    connecting = false;
    startedAt = Date.now();
    addLog("info", `Connected as ${readyClient.user.tag}`);

    try {
      const commands = [
        new SlashCommandBuilder()
          .setName("ping")
          .setDescription("Check whether the bot is responsive.")
          .toJSON()
      ];
      const rest = new REST({ version: "10" }).setToken(token);
      await rest.put(Routes.applicationCommands(readyClient.user.id), { body: commands });
      addLog("info", "Registered /ping command.");
    } catch {
      addLog("warn", "Connected, but slash-command registration failed. Check application settings.");
    }
  });

  candidate.on(Events.InteractionCreate, async (interaction) => {
    if (!interaction.isChatInputCommand()) return;
    if (interaction.commandName === "ping") {
      try {
        await interaction.reply({ content: "Pong.", ephemeral: true });
      } catch {
        addLog("warn", "Could not reply to a command interaction.");
      }
    }
  });

  candidate.on(Events.Error, () => addLog("error", "Discord client emitted an error."));
  candidate.on(Events.ShardDisconnect, () => addLog("warn", "Discord connection disconnected."));
  candidate.on(Events.ShardReconnecting, () => addLog("info", "Reconnecting to Discord."));
  candidate.on(Events.ShardReady, () => addLog("info", "Discord shard ready."));

  try {
    await candidate.login(token);
    // Do not retain the request token in application state after login.
    res.status(202).json({ ok: true, message: "Bot connection requested.", status: statusSnapshot() });
  } catch {
    client = null;
    connecting = false;
    startedAt = null;
    addLog("error", "Bot login failed. Verify the bot token in the Discord Developer Portal.");
    try { candidate.destroy(); } catch {}
    return res.status(400).json({ error: "Discord login failed. Verify the bot token." });
  }
});

app.post("/api/bot/stop", requireControlKey, async (_req, res) => {
  if (!client) return res.json({ ok: true, status: statusSnapshot() });
  const oldClient = client;
  client = null;
  connecting = false;
  startedAt = null;
  try { oldClient.destroy(); } catch {}
  addLog("info", "Bot stopped by the dashboard.");
  res.json({ ok: true, status: statusSnapshot() });
});

app.use((err, _req, res, _next) => {
  addLog("error", "Request failed.");
  res.status(400).json({ error: "Invalid request." });
});

app.listen(port, "0.0.0.0", () => {
  addLog("info", `ControlQPC bot runtime listening on port ${port}`);
});
