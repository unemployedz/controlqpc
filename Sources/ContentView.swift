import SwiftUI

private struct PanelFeature: Identifiable {
    let title: String
    let symbol: String
    let detail: String
    let isAvailable: Bool

    var id: String { title }

    static let all: [PanelFeature] = [
        .init(title: "Profile", symbol: "person.crop.circle", detail: "Device profile preview", isAvailable: true),
        .init(title: "Files", symbol: "folder", detail: "File-management demo only", isAvailable: true),
        .init(title: "Screen", symbol: "iphone", detail: "Screen sharing requires an explicit session on the enrolled device", isAvailable: true),
        .init(title: "Camera", symbol: "camera", detail: "Camera access is not implemented in this demo", isAvailable: false),
        .init(title: "Mic", symbol: "mic", detail: "Microphone access is not implemented in this demo", isAvailable: false),
        .init(title: "SMS", symbol: "envelope", detail: "Private-message collection is not supported", isAvailable: false),
        .init(title: "Contacts", symbol: "person.text.rectangle", detail: "Contact access requires explicit permission", isAvailable: true),
        .init(title: "Apps", symbol: "square.grid.2x2", detail: "Installed-app inventory depends on Android platform permissions", isAvailable: true),
        .init(title: "Keylogger", symbol: "keyboard", detail: "Unavailable: this prototype does not record keystrokes", isAvailable: false),
        .init(title: "Location", symbol: "location", detail: "Location sharing requires opt-in and platform permission", isAvailable: true),
        .init(title: "Browser", symbol: "safari", detail: "Browser activity is demo-only; no hidden browsing capture", isAvailable: true),
        .init(title: "Screen reader", symbol: "text.alignleft", detail: "Accessibility data is not collected by this demo", isAvailable: false),
        .init(title: "Clipboard", symbol: "doc.on.clipboard", detail: "Clipboard reading is not implemented", isAvailable: false),
        .init(title: "Lock screen", symbol: "lock", detail: "Remote lock depends on supported, authorized device-management APIs", isAvailable: true),
        .init(title: "Chat", symbol: "bubble.left", detail: "Secure support-message placeholder", isAvailable: true)
    ]
}

struct ContentView: View {
    @State private var selectedFeature: PanelFeature?
    @State private var selectedTab = "Clients"
    @State private var showConnectSheet = false

    private let background = Color.black
    private let panel = Color(red: 0.035, green: 0.035, blue: 0.035)
    private let accent = Color.white

    private let topItems: [(String, String)] = [
        ("antenna.radiowaves.left.and.right", "Connection"),
        ("arrow.triangle.branch", "Routes"),
        ("shippingbox", "Packages"),
        ("cpu", "Agent"),
        ("music.note", "Media"),
        ("moon.stars", "Appearance")
    ]

    private let quickActions: [(String, String)] = [
        ("arrow.up.right", "Open"),
        ("nosign", "Disconnect"),
        ("rectangle.text.magnifyingglass", "Details"),
        ("pencil", "Edit"),
        ("rectangle", "Window"),
        ("iphone.gen3", "Device"),
        ("link", "Pair")
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    brandHeader
                    header
                    clientCard
                    featureGrid
                    footer
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showConnectSheet) {
            connectSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert(item: $selectedFeature) { feature in
            Alert(
                title: Text(feature.title),
                message: Text(feature.detail),
                dismissButton: .default(Text("Close"))
            )
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
                Text("DEVICE PANEL")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(1.8)
                    .foregroundStyle(.white.opacity(0.42))
            }
            Spacer()
            Circle()
                .fill(Color.white.opacity(0.75))
                .frame(width: 6, height: 6)
            Text("LOCAL DEMO")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
    }

    private var header: some View {
        HStack(spacing: 0) {
            ForEach(Array(topItems.enumerated()), id: \.offset) { entry in
                let item = entry.element
                Button {
                    if item.1 == "Connection" { showConnectSheet = true }
                    else { selectedFeature = PanelFeature(title: item.1, symbol: item.0, detail: "This is a visual prototype. Connect a secure, authorized backend to enable supported features.", isAvailable: true) }
                } label: {
                    VStack(spacing: 7) {
                        Image(systemName: item.0)
                            .font(.system(size: 19, weight: .semibold))
                            .frame(height: 24)
                        Text(item.1)
                            .font(.system(size: 9, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundStyle(Color.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 4)
        .background(panel.opacity(0.92), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private var clientCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(accent, lineWidth: 2)
                        .frame(width: 82, height: 82)
                        .shadow(color: accent.opacity(0.35), radius: 8)
                    Image(systemName: "iphone")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(accent.opacity(0.9))
                }
                .frame(width: 94)

                VStack(alignment: .leading, spacing: 7) {
                    Text("No Client Selected")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    Text("Select an enrolled device to view details")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        showConnectSheet = true
                    } label: {
                        Label("Pair device", systemImage: "link")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(background)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(accent, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
            .padding(14)

            Divider().overlay(Color.white.opacity(0.08))

            HStack(spacing: 0) {
                ForEach(Array(quickActions.enumerated()), id: \.offset) { entry in
                    let action = entry.element
                    Button {
                        selectedFeature = PanelFeature(title: action.1, symbol: action.0, detail: "No device is connected. This control is a demo placeholder.", isAvailable: false)
                    } label: {
                        Image(systemName: action.0)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.72))
                            .frame(maxWidth: .infinity)
                            .frame(height: 43)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 5)

            HStack {
                Text("No data")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.72))
                Spacer()
                Circle()
                    .fill(accent)
                    .frame(width: 7, height: 7)
                Text("DEMO")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(accent)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color.black.opacity(0.18))
        }
        .background(panel.opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private var featureGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(PanelFeature.all) { feature in
                Button {
                    selectedFeature = feature
                } label: {
                    VStack(spacing: 9) {
                        Image(systemName: feature.symbol)
                            .font(.system(size: 23, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(feature.isAvailable ? Color.white.opacity(0.94) : Color.white.opacity(0.48))
                            .frame(height: 30)
                        Text(feature.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(feature.isAvailable ? .white : Color.white.opacity(0.55))
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        if !feature.isAvailable {
                            Text("DEMO ONLY")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .tracking(0.7)
                                .foregroundStyle(accent.opacity(0.85))
                        } else {
                            Text(" ")
                                .font(.system(size: 7))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 93)
                    .background(Color.white.opacity(0.025), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.045), lineWidth: 1))
                    .contentShape(RoundedRectangle(cornerRadius: 15))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 1)
    }

    private var footer: some View {
        HStack(spacing: 0) {
            footerItem("Clients", count: "0", symbol: "person.2")
            footerItem("Servers", count: "1", symbol: "server.rack")
            footerItem("Settings", count: nil, symbol: "slider.horizontal.3")
        }
        .padding(.top, 4)
    }

    private func footerItem(_ title: String, count: String?, symbol: String) -> some View {
        Button {
            selectedTab = title
            if title == "Settings" {
                selectedFeature = PanelFeature(title: "Settings", symbol: symbol, detail: "Prototype settings. No remote device is connected.", isAvailable: true)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                if let count {
                    Text(count)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(accent)
                }
            }
            .foregroundStyle(selectedTab == title ? Color.white : Color.white.opacity(0.58))
            .padding(.horizontal, 13)
            .padding(.vertical, 10)
            .background(selectedTab == title ? Color.white.opacity(0.08) : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var connectSheet: some View {
        ZStack {
            background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                Text("Connect a device")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.white)
                Text("This prototype does not connect to a real device yet.")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.72))
                Label("Secure enrollment will use a one-time pairing code.", systemImage: "lock.shield")
                    .font(.system(size: 13))
                    .foregroundStyle(accent)
                Spacer()
                Button("Done") { showConnectSheet = false }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(accent, in: RoundedRectangle(cornerRadius: 13))
            }
            .padding(24)
        }
    }
}
