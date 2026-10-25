import SwiftUI

private enum RunMode: String, CaseIterable, Identifiable {
    case test = "Local test"
    case cloud = "Cloud"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .test: return "iphone"
        case .cloud: return "cloud"
        }
    }

    var subtitle: String {
        switch self {
        case .test: return "Preview commands on this device"
        case .cloud: return "Run independently in the cloud"
        }
    }
}

private struct BotTool: Identifiable {
    let title: String
    let symbol: String
    let detail: String
    var id: String { title }

    static let all: [BotTool] = [
        .init(title: "Commands", symbol: "terminal", detail: "Create and manage slash commands."),
        .init(title: "Auto replies", symbol: "bubble.left.and.bubble.right", detail: "Set up keyword responses and canned replies."),
        .init(title: "Welcome", symbol: "hand.wave", detail: "Configure welcome messages for new members."),
        .init(title: "Embeds", symbol: "rectangle.on.rectangle", detail: "Design rich embed messages."),
        .init(title: "Moderation", symbol: "shield", detail: "Configure permission-aware moderation tools."),
        .init(title: "Activity", symbol: "waveform.path", detail: "Set the bot's supported presence and activity.")
    ]
}

struct ContentView: View {
    @State private var selectedMode: RunMode = .test
    @State private var botName = "My Discord Bot"
    @State private var botToken = ""
    @State private var tokenVisible = false
    @State private var isPreviewRunning = false
    @State private var selectedTool: BotTool?
    @State private var showTokenInfo = false
    @State private var selectedTab = "Overview"
    @State private var runtimeURL = "https://controlqpc-bot-runtime.onrender.com"
    @State private var controlKey = ""
    @State private var cloudStatus = "Not checked"
    @State private var cloudUsername = "—"
    @State private var cloudGuildCount = "—"
    @State private var cloudUptime = "—"
    @State private var cloudLogs: [String] = []
    @State private var cloudBusy = false
    @State private var cloudError = ""

    private let panel = Color(red: 0.045, green: 0.045, blue: 0.045)
    private let muted = Color.white.opacity(0.52)
    private let stroke = Color.white.opacity(0.085)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    brandHeader
                    titleBlock
                    modePicker
                    botCard
                    tokenCard
                    cloudSettingsCard
                    toolsSection
                    consoleCard
                    bottomNavigation
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $selectedTool) { tool in
            toolSheet(tool)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert("Keep your bot token private", isPresented: $showTokenInfo) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("Your bot token is sent only when you tap Start Cloud Bot, over HTTPS to your configured runtime. Never share your token or control key. Rotate the bot token immediately if it is exposed.")
        }
    }

    private var brandHeader: some View {
        HStack(spacing: 11) {
            BrandMark()
                .frame(width: 38, height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text("CONTROLQPC")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundStyle(.white)
                Text("CLOUD BOT STUDIO")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(1.6)
                    .foregroundStyle(muted)
            }
            Spacer()
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(.white.opacity(0.7))
            Text("PRIVATE")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(0.9)
                .foregroundStyle(muted)
        }
        .padding(.vertical, 4)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Bot workspace")
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Build, test, and manage your Discord bot.")
                .font(.system(size: 13))
                .foregroundStyle(muted)
        }
        .padding(.top, 4)
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("RUN MODE")
            HStack(spacing: 8) {
                ForEach(RunMode.allCases) { mode in
                    Button {
                        selectedMode = mode
                    } label: {
                        HStack(spacing: 9) {
                            Image(systemName: mode.symbol)
                                .font(.system(size: 16, weight: .semibold))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mode.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                Text(mode.subtitle)
                                    .font(.system(size: 10))
                                    .foregroundStyle(selectedMode == mode ? .white.opacity(0.62) : muted)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(.white)
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
                        .background(selectedMode == mode ? Color.white.opacity(0.105) : panel,
                                    in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(selectedMode == mode ? Color.white.opacity(0.3) : stroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var botCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                sectionLabel("BOT OVERVIEW")
                Spacer()
                statusPill(selectedMode == .test ? (isPreviewRunning ? "PREVIEW ACTIVE" : "LOCAL IDLE") : cloudStatus.uppercased(),
                           active: selectedMode == .test ? isPreviewRunning : cloudStatus == "Running")
            }

            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 58, height: 58)
                    Image(systemName: "cpu")
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 5) {
                    TextField("Bot name", text: $botName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .textInputAutocapitalization(.words)
                    Text(selectedMode == .test ? "LOCAL TEST WORKSPACE" : "CLOUD DEPLOYMENT")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(muted)
                }
            }

            HStack(spacing: 0) {
                metric("RUNTIME", value: selectedMode == .test ? (isPreviewRunning ? "Preview" : "Idle") : cloudStatus)
                Spacer()
                metric("SERVERS", value: selectedMode == .test ? "—" : cloudGuildCount)
                Spacer()
                metric("UPTIME", value: selectedMode == .test ? "—" : cloudUptime)
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 12)
            .background(Color.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 12))

            Button {
                if selectedMode == .test {
                    isPreviewRunning.toggle()
                } else {
                    Task { await toggleCloudBot() }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: selectedMode == .test
                          ? (isPreviewRunning ? "stop.fill" : "play.fill")
                          : "cloud.upload")
                    Text(selectedMode == .test
                         ? (isPreviewRunning ? "Stop local preview" : "Start local preview")
                         : (cloudBusy ? "Connecting..." : (cloudStatus == "Running" ? "Stop Cloud Bot" : "Start Cloud Bot")))
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(cloudBusy)

            Text(selectedMode == .test
                 ? "Local preview simulates the interface and command flow; it does not connect to Discord."
                 : "Cloud mode sends your token to the configured HTTPS runtime. Keep the control key private.")
                .font(.system(size: 11))
                .foregroundStyle(muted)
                .fixedSize(horizontal: false, vertical: true)

            if !cloudError.isEmpty {
                Text(cloudError)
                    .font(.system(size: 11))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
                .font(.system(size: 11))
                .foregroundStyle(muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(15)
        .background(panel, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(stroke, lineWidth: 1))
    }

    private var tokenCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionLabel("BOT CREDENTIALS")
                Spacer()
                Button {
                    showTokenInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundStyle(muted)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                Image(systemName: "key.horizontal")
                    .foregroundStyle(muted)
                Group {
                    if tokenVisible {
                        TextField("Paste bot token for future setup", text: $botToken)
                    } else {
                        SecureField("Paste bot token for future setup", text: $botToken)
                    }
                }
                .font(.system(size: 12, design: .monospaced))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                Button {
                    tokenVisible.toggle()
                } label: {
                    Image(systemName: tokenVisible ? "eye.slash" : "eye")
                        .foregroundStyle(muted)
                }
                .buttonStyle(.plain)
            }
            .padding(13)
            .background(Color.black, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(stroke, lineWidth: 1))

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lock.shield")
                    .foregroundStyle(.white.opacity(0.8))
                Text("The token stays in this screen until you start the cloud bot. It is not saved by the app.")
                    .font(.system(size: 11))
                    .foregroundStyle(muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(15)
        .background(panel, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(stroke, lineWidth: 1))
    }

    private var cloudSettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionLabel("CLOUD CONNECTION")
                Spacer()
                Button {
                    Task { await refreshCloudStatus() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(cloudBusy)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Runtime URL")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(muted)
                TextField("https://your-runtime.onrender.com", text: $runtimeURL)
                    .font(.system(size: 12, design: .monospaced))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .padding(12)
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 11))
                    .overlay(RoundedRectangle(cornerRadius: 11).stroke(stroke, lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 7) {
                Text("Private control key")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(muted)
                SecureField("Paste Render CONTROLQPC_CONTROL_KEY", text: $controlKey)
                    .font(.system(size: 12, design: .monospaced))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 11))
                    .overlay(RoundedRectangle(cornerRadius: 11).stroke(stroke, lineWidth: 1))
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lock.shield")
                    .foregroundStyle(.white.opacity(0.85))
                Text("Get the control key from your Render service environment settings. Do not paste it into GitHub or share it.")
                    .font(.system(size: 11))
                    .foregroundStyle(muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !cloudLogs.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    Text("RUNTIME LOGS")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(muted)
                    ForEach(Array(cloudLogs.suffix(8).enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black, in: RoundedRectangle(cornerRadius: 11))
            }
        }
        .padding(15)
        .background(panel, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(stroke, lineWidth: 1))
    }

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                sectionLabel("BOT BUILDER")
                Spacer()
                Text("6 MODULES")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(muted)
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 9), GridItem(.flexible(), spacing: 9)], spacing: 9) {
                ForEach(BotTool.all) { tool in
                    Button {
                        selectedTool = tool
                    } label: {
                        VStack(alignment: .leading, spacing: 13) {
                            Image(systemName: tool.symbol)
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(.white)
                            Text(tool.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white)
                            HStack {
                                Text("CONFIGURE")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .tracking(0.7)
                                    .foregroundStyle(muted)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(muted)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
                        .background(panel, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(stroke, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var consoleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionLabel("LIVE CONSOLE")
                Spacer()
                Image(systemName: "terminal")
                    .foregroundStyle(muted)
            }
            VStack(alignment: .leading, spacing: 8) {
                consoleLine("controlqpc", "workspace initialized")
                consoleLine("runtime", selectedMode == .test ? "local test selected" : "cloud runtime not connected")
                consoleLine("security", "credentials are not transmitted")
                if isPreviewRunning {
                    consoleLine("preview", "UI preview started")
                }
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(15)
        .background(panel, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(stroke, lineWidth: 1))
    }

    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            navItem("Overview", symbol: "square.grid.2x2")
            navItem("Commands", symbol: "terminal")
            navItem("Deploys", symbol: "cloud")
            navItem("Settings", symbol: "slider.horizontal.3")
        }
        .padding(5)
        .background(panel, in: Capsule())
        .overlay(Capsule().stroke(stroke, lineWidth: 1))
    }

    private func navItem(_ title: String, symbol: String) -> some View {
        Button {
            selectedTab = title
            if title == "Commands" {
                selectedTool = BotTool.all[0]
            } else if title == "Deploys" {
                selectedMode = .cloud
            } else if title == "Settings" {
                showTokenInfo = true
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundStyle(selectedTab == title ? .white : muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(selectedTab == title ? Color.white.opacity(0.09) : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func toolSheet(_ tool: BotTool) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: tool.symbol)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
                Text(tool.title)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.white)
                Text(tool.detail)
                    .font(.system(size: 14))
                    .foregroundStyle(muted)
                Text("Builder UI preview — connect the bot backend to enable saving and execution.")
                    .font(.system(size: 12))
                    .foregroundStyle(muted)
                Spacer()
                Button("Done") { selectedTool = nil }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(.white, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }

    private func toggleCloudBot() async {
        guard !cloudBusy else { return }
        cloudError = ""
        guard let base = URL(string: runtimeURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              base.scheme == "https", base.host != nil else {
            cloudError = "Enter a valid HTTPS runtime URL."
            return
        }
        guard !controlKey.isEmpty else {
            cloudError = "Paste the private control key from Render first."
            return
        }
        cloudBusy = true
        defer { cloudBusy = false }

        if cloudStatus == "Running" {
            do {
                _ = try await cloudRequest(path: "/api/bot/stop", method: "POST")
                cloudStatus = "Stopped"
                cloudUsername = "—"
                cloudGuildCount = "0"
                cloudUptime = "—"
                await refreshCloudLogs()
            } catch {
                cloudError = "Could not stop the bot. Check the runtime URL and control key."
            }
            return
        }

        guard !botToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cloudError = "Paste your Discord bot token above before starting."
            return
        }

        do {
            let body: [String: Any] = [
                "token": botToken.trimmingCharacters(in: .whitespacesAndNewlines),
                "name": botName
            ]
            let data = try JSONSerialization.data(withJSONObject: body)
            _ = try await cloudRequest(path: "/api/bot/start", method: "POST", body: data)
            botToken = ""
            tokenVisible = false
            cloudStatus = "Connecting"
            cloudBusy = false
            await refreshCloudStatus()
            await refreshCloudLogs()
        } catch {
            cloudError = "Could not start the bot. Verify the token, bot application, runtime URL, and control key."
        }
    }

    private func refreshCloudStatus() async {
        guard !cloudBusy else { return }
        guard !controlKey.isEmpty,
              let base = URL(string: runtimeURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              base.scheme == "https", base.host != nil else {
            cloudError = "Enter the HTTPS runtime URL and private control key."
            return
        }
        cloudError = ""
        cloudBusy = true
        defer { cloudBusy = false }
        do {
            let data = try await cloudRequest(path: "/api/bot/status", method: "GET")
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            let running = json["running"] as? Bool ?? false
            let connecting = json["connecting"] as? Bool ?? false
            cloudStatus = running ? "Running" : (connecting ? "Connecting" : "Stopped")
            cloudUsername = json["username"] as? String ?? "—"
            cloudGuildCount = String(json["guildCount"] as? Int ?? 0)
            let seconds = json["uptimeSeconds"] as? Int ?? 0
            cloudUptime = running ? "\(seconds)s" : "—"
            await refreshCloudLogs()
        } catch {
            cloudStatus = "Unreachable"
            cloudError = "Runtime could not be reached. On Render's free plan it may take a moment to wake up."
        }
    }

    private func refreshCloudLogs() async {
        do {
            let data = try await cloudRequest(path: "/api/bot/logs", method: "GET")
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            let logs = json["logs"] as? [[String: Any]] ?? []
            cloudLogs = logs.compactMap { item in
                guard let level = item["level"] as? String,
                      let message = item["message"] as? String else { return nil }
                return "[\(level)] \(message)"
            }
        } catch {
            cloudLogs = ["Logs unavailable."]
        }
    }

    private func cloudRequest(path: String, method: String, body: Data? = nil) async throws -> Data {
        guard let base = URL(string: runtimeURL.trimmingCharacters(in: .whitespacesAndNewlines)),
              let url = URL(string: path, relativeTo: base) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 35
        request.setValue("Bearer \(controlKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpBody = body
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return data
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .tracking(1.25)
            .foregroundStyle(muted)
    }

    private func statusPill(_ title: String, active: Bool) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(active ? Color.white : Color.white.opacity(0.35))
                .frame(width: 5, height: 5)
            Text(title)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(0.5)
        }
        .foregroundStyle(active ? .white : muted)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(active ? 0.12 : 0.05), in: Capsule())
    }

    private func metric(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(muted)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }

    private func consoleLine(_ source: String, _ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(source)
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 74, alignment: .leading)
            Text(message)
                .foregroundStyle(muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.system(size: 10, design: .monospaced))
    }
}
