import SwiftUI

/// Application entry point. Resolves the `AppEnvironment` (mock in DEBUG,
/// live in RELEASE), registers bundled fonts at process start, and hands
/// the view tree to `AppShell`. The whole app is locked to `.light` for
/// now — dark-mode tuning is on the roadmap, see the project README.
@main
struct takehomeApp: App {
    private let environment: AppEnvironment = .resolved()

    init() {
        // Custom OTFs/TTFs are registered with CoreText in code rather than
        // via `INFOPLIST_KEY_UIAppFonts` so that adding a new font is just
        // "drop the file in `Resources/Fonts/`."
        FontRegistration.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppShell()
                .applyAppEnvironment(environment)
                .preferredColorScheme(.light)
        }
    }
}
