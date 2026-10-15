import SwiftUI

@main
struct HotspotProxyApp: App {
    @StateObject private var model = ProxyModel()
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    private var forceOnboarding: Bool { ProcessInfo.processInfo.arguments.contains("-showOnboarding") }
    private var skipOnboarding: Bool { ProcessInfo.processInfo.arguments.contains("-skipOnboarding") }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(model)
                .tint(.accentColor)
                .onOpenURL { url in
                    if let link = DeepLink(url: url) { model.handle(link) }
                }
                .fullScreenCover(isPresented: Binding(
                    get: { forceOnboarding || (!hasOnboarded && !skipOnboarding) },
                    set: { if !$0 { hasOnboarded = true } }
                )) {
                    OnboardingView(isPresented: Binding(
                        get: { true },
                        set: { if !$0 { hasOnboarded = true } }
                    ))
                }
        }
    }
}
