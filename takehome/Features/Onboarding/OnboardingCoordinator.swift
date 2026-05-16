import Observation
import SwiftUI

/// Source of truth for the onboarding `NavigationStack`. Each step-completion
/// callback (`didSignIn`, `didCapture`, `didRecord`) appends the next route
/// with all the data the step needs threaded through its associated values
/// — there is no shared mutable onboarding state object. `reset()` is called
/// after the Success screen dismisses to return the user to sign-in.
@Observable
final class OnboardingCoordinator {
    /// Backing path bound to `NavigationStack(path:)` in `OnboardingFlowView`.
    var path: [OnboardingRoute] = []

    /// Sign-in succeeded → push camera step with the verified phone number.
    func didSignIn(_ phone: E164) {
        path.append(.camera(phone: phone))
    }

    /// Camera captured a selfie → push voice step, threading phone forward.
    func didCapture(selfie: URL, phone: E164) {
        path.append(.voice(phone: phone, selfie: selfie))
    }

    /// Voice recording accepted → push success step with all collected media.
    func didRecord(voice: URL, phone: E164, selfie: URL) {
        path.append(.success(phone: phone, selfie: selfie, voice: voice))
    }

    /// Clears the stack so the next presentation starts fresh at sign-in.
    func reset() {
        path.removeAll()
    }
}
