import Foundation
import Testing
@testable import takehome

/// The coordinator is the navigation state machine. These tests verify each
/// step appends the correct payload-bearing route, that `reset()` returns to
/// the SignIn root, and that data threads forward through the route enum so
/// later steps can never land without the preceding step's output.
@MainActor
@Suite("OnboardingCoordinator")
struct OnboardingCoordinatorTests {
    private let phone = E164(countryCode: "1", national: "2025550123")
    private let selfie = URL(fileURLWithPath: "/tmp/coord-selfie.jpg")
    private let voice = URL(fileURLWithPath: "/tmp/coord-voice.m4a")

    @Test func didSignIn_appends_camera_route() {
        let coord = OnboardingCoordinator()
        coord.didSignIn(phone)
        #expect(coord.path == [.camera(phone: phone)])
    }

    @Test func didCapture_threads_phone_forward_into_voice_route() {
        let coord = OnboardingCoordinator()
        coord.didSignIn(phone)
        coord.didCapture(selfie: selfie, phone: phone)
        #expect(coord.path.last == .voice(phone: phone, selfie: selfie))
    }

    @Test func didRecord_threads_all_payload_into_success_route() {
        let coord = OnboardingCoordinator()
        coord.didSignIn(phone)
        coord.didCapture(selfie: selfie, phone: phone)
        coord.didRecord(voice: voice, phone: phone, selfie: selfie)
        #expect(coord.path.last == .success(phone: phone, selfie: selfie, voice: voice))
        #expect(coord.path.count == 3)
    }

    @Test func reset_returns_to_signIn_root() {
        let coord = OnboardingCoordinator()
        coord.didSignIn(phone)
        coord.didCapture(selfie: selfie, phone: phone)
        coord.reset()
        #expect(coord.path.isEmpty)
    }

    @Test func route_payload_is_hashable_and_distinct_by_data() {
        let a: OnboardingRoute = .voice(phone: phone, selfie: selfie)
        let b: OnboardingRoute = .voice(phone: phone, selfie: selfie)
        let c: OnboardingRoute = .voice(
            phone: phone,
            selfie: URL(fileURLWithPath: "/tmp/different.jpg")
        )
        #expect(a == b)
        #expect(a != c)
    }
}
