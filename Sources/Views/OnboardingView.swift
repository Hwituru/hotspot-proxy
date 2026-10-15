import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var page = 0

    private let pages: [(ProxySnapshot.Status, String, String)] = [
        (.running, "Your iPhone as a Proxy", "Macs, iPads, and laptops on your hotspot reach the internet through this iPhone. HTTP, HTTPS, and SOCKS5 on a single port."),
        (.noHotspot, "Turn On Your Hotspot", "In Settings › Personal Hotspot, enable ‘Allow Others to Join’. Allow local network access when the app first asks."),
        (.stopped, "Stays On in the Background", "Silent audio keeps the proxy alive with the screen off. Add the Lock Screen widget to see status and address at a glance."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") { isPresented = false }
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
            .accessibilityLabel("Page \(page + 1) of \(pages.count)")

            Button {
                if page < pages.count - 1 {
                    withAnimation(Motion.standard) { page += 1 }
                } else {
                    isPresented = false
                }
            } label: {
                Text(page < pages.count - 1 ? "Next" : "Get Started")
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
