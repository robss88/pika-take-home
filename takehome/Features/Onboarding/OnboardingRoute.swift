import Foundation

/// Each step's payload carries the data captured at every prior step forward.
/// No shared mutable model — payload through types.
enum OnboardingRoute: Hashable {
    case camera(phone: E164)
    case voice(phone: E164, selfie: URL)
    case success(phone: E164, selfie: URL, voice: URL)
}
