import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var page = 0

    private let pages: [(ProxySnapshot.Status, String, String)] = [
        (.running, "아이폰을 프록시로", "핫스팟에 연결된 Mac, iPad, 노트북이 이 아이폰을 거쳐 인터넷을 씁니다. HTTP · HTTPS · SOCKS5를 한 포트에서 받습니다."),
        (.noHotspot, "핫스팟을 켜 주세요", "설정 › 개인용 핫스팟에서 ‘다른 사람의 연결 허용’을 켭니다. 처음 시작할 때 로컬 네트워크 접근을 허용해 주세요."),
        (.stopped, "백그라운드에서도 유지", "화면을 꺼도 프록시가 살아 있도록 소리 없는 오디오를 재생합니다. 잠금화면 위젯을 추가하면 상태와 주소를 바로 확인할 수 있습니다."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("건너뛰기") { isPresented = false }
                    .font(.body)
                    .frame(minHeight: 44)
                    .opacity(page < pages.count - 1 ? 1 : 0)
            }
            .padding(.horizontal, Space.l)

            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { i in
                    VStack(spacing: Space.xl) {
                        Spacer(minLength: 0)
                        SignalRing(status: pages[i].0, size: 180)
                        VStack(spacing: Space.m) {
                            Text(pages[i].1)
                                .font(.title.weight(.bold))
                                .multilineTextAlignment(.center)
                            Text(pages[i].2)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, Space.xl)
                        Spacer(minLength: 0)
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: Space.s) {
                ForEach(pages.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: i == page ? 22 : 8, height: 8)
                }
            }
            .animation(Motion.standard, value: page)
            .padding(.bottom, Space.xl)
            .accessibilityElement()
            .accessibilityLabel("\(page + 1) / \(pages.count) 페이지")

            Button {
                if page < pages.count - 1 {
                    withAnimation(Motion.standard) { page += 1 }
                } else {
                    isPresented = false
                }
            } label: {
                Text(page < pages.count - 1 ? "다음" : "시작하기")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Capsule().fill(Color.accentColor.gradient))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, Space.l)
            .padding(.bottom, Space.l)
            .sensoryFeedback(.selection, trigger: page)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
