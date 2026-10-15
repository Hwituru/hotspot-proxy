import SwiftUI

struct ConnectGuideView: View {
    @EnvironmentObject var m: ProxyModel

    var body: some View {
        List {
            Section {
                if let ip = m.hotspotIP {
                    CopyableRow(title: "서버", value: ip)
                } else {
                    LabeledContent("서버", value: "핫스팟 꺼짐 (보통 172.20.10.1)")
                }
                CopyableRow(title: "포트", value: String(m.port))
            } header: {
                Text("입력할 값")
            } footer: {
                Text("HTTP · HTTPS · SOCKS5 모두 같은 서버와 포트를 씁니다.")
            }

            Section("iPhone · iPad") {
                SetupStep(number: 1, title: "핫스팟 Wi-Fi에 연결", detail: "설정 › Wi-Fi에서 이 아이폰의 핫스팟을 선택합니다.")
                SetupStep(number: 2, title: "네트워크 정보 열기", detail: "연결된 네트워크 옆의 (i) 버튼을 누릅니다.")
                SetupStep(number: 3, title: "프록시 구성 › 수동", detail: "서버와 포트를 위 값으로 입력하고 저장합니다.")
            }
            Section("macOS") {
                SetupStep(number: 1, title: "시스템 설정 › 네트워크 › Wi-Fi", detail: "연결된 핫스팟의 ‘세부사항…’을 누릅니다.")
                SetupStep(number: 2, title: "프록시 탭", detail: "웹 프록시(HTTP), 보안 웹 프록시(HTTPS), SOCKS 프록시를 켜고 서버와 포트를 입력합니다.")
                SetupStep(number: 3, title: "또는 자동 TUN", detail: "모든 앱 트래픽을 자동으로 넘기려면 ‘Mac 자동 연결’ 안내를 따르세요.")
            }
            Section("Android") {
                SetupStep(number: 1, title: "Wi-Fi 네트워크 길게 누르기", detail: "네트워크 수정 › 고급 옵션 › 프록시 › 수동.")
                SetupStep(number: 2, title: "호스트와 포트 입력", detail: "위 서버와 포트를 입력하고 저장합니다.")
            }
            Section("Windows") {
                SetupStep(number: 1, title: "설정 › 네트워크 및 인터넷 › 프록시", detail: "수동 프록시 설정 › 프록시 서버 사용을 켭니다.")
                SetupStep(number: 2, title: "주소와 포트 입력", detail: "위 서버와 포트를 입력하고 저장합니다.")
            }
        }
        .navigationTitle("연결 방법")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MacSetupView: View {
    private let commands: [(String, String)] = [
        ("sing-box 설치", "brew install sing-box"),
        ("자동 TUN 설치", "sudo bash mac/install.sh"),
        ("제거", "sudo bash mac/uninstall.sh"),
        ("Tailscale CLI 전환 (선택)", "sudo bash mac/install-tailscale.sh"),
    ]

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: Space.s) {
                    Label("작동 방식", systemImage: "bolt.horizontal.circle")
                        .font(.headline)
                    Text("Mac이 아이폰 핫스팟(172.20.10.x)에 붙고 이 앱의 프록시(172.20.10.1:8080)가 응답하면, sing-box TUN이 자동으로 켜져 모든 트래픽을 프록시로 보냅니다. 핫스팟을 떠나면 자동으로 꺼지고 DNS도 원래대로 돌아갑니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, Space.xs)
            }
            Section {
                ForEach(commands, id: \.1) { c in
                    CopyableRow(title: c.0, value: c.1)
                }
            } header: {
                Text("터미널 명령")
            } footer: {
                Text("저장소의 mac/ 디렉터리에서 실행합니다. 네트워크가 바뀔 때와 30초마다 상태를 확인합니다.")
            }
        }
        .navigationTitle("Mac 자동 연결")
        .navigationBarTitleDisplayMode(.inline)
    }
}
