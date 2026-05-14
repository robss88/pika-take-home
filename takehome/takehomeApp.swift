import SwiftUI

@main
struct takehomeApp: App {
    private let environment: AppEnvironment = .resolved()

    init() {
        FontRegistration.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .applyAppEnvironment(environment)
                .preferredColorScheme(.light)
        }
    }
}
