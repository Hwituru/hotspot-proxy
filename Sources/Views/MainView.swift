import SwiftUI

struct MainView: View {
    @EnvironmentObject var m: ProxyModel
    @Environment(\.scenePhase) private var phase
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var showSettings = ProcessInfo.processInfo.arguments.contains("-showSettings")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Space.l) {
                    StatusHero(status: m.status, endpoint: m.endpoint, errorMessage: m.error,
                               onCopy: { m.copyEndpoint() }, onRetry: { m.start() })
                    PowerButton(running: m.running) { m.toggle() }
                    stats
                    guideLink
                }
                .padding(.horizontal, Space.l)
                .padding(.bottom, Space.xxl)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("핫스팟 프록시")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel("설정")
                }
            }
            .navigationDestination(for: Guide.self) { g in
                switch g {
                case .connect: ConnectGuideView()
                case .mac: MacSetupView()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(m)
            }
        }
        .onChange(of: phase, initial: true) { _, p in m.setVisible(p == .active) }
    }

    private var stats: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: Space.s))
            : AnyLayout(HStackLayout(spacing: Space.s))
        return layout {
            StatTile(symbol: "point.3.connected.trianglepath.dotted", label: "활성 연결") {
                Text(verbatim: String(m.connections))
            }
            StatTile(symbol: "arrow.up.arrow.down", label: "전송량") {
                Text(Format.bytes(m.bytes))
            }
            StatTile(symbol: "clock", label: "가동 시간") {
                if let start = m.startedAt, m.running {
                    TimelineView(.periodic(from: .now, by: 1)) { ctx in
                        Text(Duration.seconds(max(0, ctx.date.timeIntervalSince(start))),
                             format: .time(pattern: .hourMinuteSecond))
                    }
                } else {
                    Text("–")
                }
            }
        }
        .animation(Motion.standard, value: m.connections)
    }

    private var guideLink: some View {
        VStack(spacing: 0) {
            NavigationLink(value: Guide.connect) {
                GuideRow(symbol: "laptopcomputer.and.iphone", title: "다른 기기 연결 방법", subtitle: "iPhone · Mac · Android · Windows")
            }
            Divider().padding(.leading, 56)
            NavigationLink(value: Guide.mac) {
                GuideRow(symbol: "macbook", title: "Mac 자동 연결 (TUN)", subtitle: "핫스팟에 붙으면 모든 트래픽 자동 프록시")
            }
        }
        .buttonStyle(.plain)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Radius.tile, style: .continuous))
    }
}

enum Guide: Hashable { case connect, mac }

private struct GuideRow: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: Space.m) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body).foregroundStyle(.primary)
                Text(subtitle).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, Space.l)
        .padding(.vertical, Space.m)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}
