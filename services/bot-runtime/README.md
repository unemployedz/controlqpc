# ControlQPC Bot Runtime

A small Node.js runtime for a user's own Discord bot. The SwiftUI app remains a separate dashboard.

## Endpoints

- `GET /health` — public health check; does not reveal bot state.
- `GET /api/bot/status` — authenticated status.
- `GET /api/bot/logs` — authenticated sanitized logs.
- `POST /api/bot/start` — authenticated JSON body: `{"token":"...","name":"My Bot"}`.
- `POST /api/bot/stop` — authenticated stop.

Authenticated routes require `Authorization: Bearer <CONTROLQPC_CONTROL_KEY>`.

## Deploy to Render

Create a Node web service from this repository:
- Runtime: Node
- Build command: `cd services/bot-runtime && npm install`
- Start command: `cd services/bot-runtime && npm start`
- Health check path: `/health`
- Set `CONTROLQPC_CONTROL_KEY` to a strong random secret (32+ characters).
- Optionally set `ALLOWED_ORIGIN` to the exact origin of a web dashboard.

## Important limitations

- This first runtime keeps the connected client in memory. A restart or deploy disconnects it; bot configuration is not persisted.
- It supports one bot process per service.
- Only the minimum Guilds intent is enabled. The sample `/ping` command does not read message content.
- Tokens are not printed in logs or saved to disk by this service. HTTPS is required in production.
- Treat the control key like a password. Do not commit it to GitHub or put it in public client code. The native app should store it in Keychain and send it only over HTTPS.
- This is not yet a complete multi-user hosting platform or a guarantee of uninterrupted uptime.
