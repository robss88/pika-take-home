import Observation
import SwiftUI

@Observable
final class OnboardingCoordinator {
    var path: [OnboardingRoute] = []

    func didSignIn(_ phone: E164) {
        path.append(.camera(phone: phone))
    }

    func didCapture(selfie: URL, phone: E164) {
        path.append(.voice(phone: phone, selfie: selfie))
    }

    func didRecord(voice: URL, phone: E164, selfie: URL) {
        path.append(.success(phone: phone, selfie: selfie, voice: voice))
    }

    func reset() {
        path.removeAll()
    }
}
