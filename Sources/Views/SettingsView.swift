import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var m: ProxyModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var portText = ""
    @FocusState private var portFocused: Bool

    private var version: String {
        let info = Bundle.main.infoDictionary
        let v = info?["CFBundleShortVersionString"] as? String ?? "–"
        let b = info?["CFBundleVersion"] as? String ?? "–"
        return "\(v) (\(b))"
    }

    private var portValid: Bool { Int(portText).map { (1024...65535).contains($0) } ?? false }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("포트") {
                        TextField("8080", text: $portText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .focused($portFocused)
                            .foregroundStyle(portValid || portText.isEmpty ? Color.primary : Color.red)
                            .onSubmit(commitPort)
                            .accessibilityLabel("포트 번호")
                    }
                    .disabled(m.running)
                    Toggle("앱 실행 시 자동 시작", isOn: $m.autoStart)
                } header: {
                    Text("프록시")
                } footer: {
                    if m.running {
                        Text("포트를 바꾸려면 먼저 프록시를 중지하세요.")
                    } else if !portValid && !portText.isEmpty {
                        Text("1024에서 65535 사이의 숫자를 입력하세요.").foregroundStyle(.red)
                    } else {
                        Text("HTTP, HTTPS, SOCKS5 모두 같은 포트를 사용합니다.")
                    }
                }

                Section {
                    if m.addresses.isEmpty {
                        Text("활성 네트워크 인터페이스가 없습니다").foregroundStyle(.secondary)
                    }
                    ForEach(m.addresses, id: \.0) { a in
                        CopyableRow(title: a.0.hasPrefix("bridge") ? "\(a.0) · 핫스팟" : a.0, value: a.1)
                    }
                } header: {
                    Text("네트워크 인터페이스")
                } footer: {
                    Text("bridge로 시작하는 인터페이스가 개인용 핫스팟입니다. 다른 기기는 이 주소로 접속합니다.")
                }

                Section("도움말") {
                    NavigationLink { ConnectGuideView() } label: {
                        Label("다른 기기 연결 방법", systemImage: "laptopcomputer.and.iphone")
                    }
                    NavigationLink { MacSetupView() } label: {
                        Label("Mac 자동 연결 (TUN)", systemImage: "macbook")
                    }
                    Button {
                        hasOnboarded = false
                        dismiss()
                    } label: {
                        Label("온보딩 다시 보기", systemImage: "sparkles")
                    }
                }

                Section {
                    LabeledContent("버전", value: version)
                    Link(destination: URL(string: "https://github.com/Indosaram/hotspot-proxy")!) {
                        Label("GitHub 저장소", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                } header: {
                    Text("정보")
                } footer: {
                    Text("백그라운드에서 프록시를 유지하기 위해 소리 없는 오디오를 재생합니다. 프록시를 중지하면 함께 멈춥니다.")
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { commitPort(); dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("확인") { commitPort(); portFocused = false }
                }
            }
            .onAppear { portText = String(m.port) }
        }
    }

    private func commitPort() {
        guard let v = Int(portText), m.setPort(v) else {
            if !portValid { portText = String(m.port) }
            return
        }
    }
}
