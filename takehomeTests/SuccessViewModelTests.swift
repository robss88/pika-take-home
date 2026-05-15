import Foundation
import Testing
@testable import takehome

@MainActor
@Suite("SuccessViewModel")
struct SuccessViewModelTests {
    private static let selfieURL = URL(fileURLWithPath: "/tmp/test-selfie.jpg")
    private static let voiceURL  = URL(fileURLWithPath: "/tmp/test-voice.m4a")
    private static let phone = E164(countryCode: "1", national: "2025550123")

    @Test func loaded_state_after_successful_creation() async {
        let vm = SuccessViewModel(
            client: MockOnboardingClient(delay: .zero),
            phone: Self.phone,
            selfieURL: Self.selfieURL,
            voiceURL: Self.voiceURL,
            openMessages: { },
            onDismiss: { }
        )
        await vm.load()
        guard case .loaded(let card) = vm.loadState else {
            Issue.record("expected .loaded, got \(vm.loadState)")
            return
        }
        #expect(card.name == "SEMI")
    }

    @Test func error_state_when_client_fails() async {
        let vm = SuccessViewModel(
            client: MockOnboardingClient(delay: .zero, shouldFail: true),
            phone: Self.phone,
            selfieURL: Self.selfieURL,
            voiceURL: Self.voiceURL,
            openMessages: { },
            onDismiss: { }
        )
        await vm.load()
        if case .error = vm.loadState {
            // expected
        } else {
            Issue.record("expected .error, got \(vm.loadState)")
        }
    }

    @Test func dismiss_invokes_callback() {
        var dismissed = false
        let vm = SuccessViewModel(
            client: MockOnboardingClient(delay: .zero),
            phone: Self.phone,
            selfieURL: Self.selfieURL,
            voiceURL: Self.voiceURL,
            openMessages: { },
            onDismiss: { dismissed = true }
        )
        vm.dismiss()
        #expect(dismissed)
    }

    @Test func openMessages_closure_is_held_and_callable() {
        var opened = 0
        let vm = SuccessViewModel(
            client: MockOnboardingClient(delay: .zero),
            phone: Self.phone,
            selfieURL: Self.selfieURL,
            voiceURL: Self.voiceURL,
            openMessages: { opened += 1 },
            onDismiss: { }
        )
        vm.openMessages()
        vm.openMessages()
        #expect(opened == 2)
    }

    @Test func loaded_card_echoes_selfie_url_through_mock_pipeline() async {
        let selfieURL = URL(fileURLWithPath: "/tmp/avatar-echo.jpg")
        let vm = SuccessViewModel(
            client: MockOnboardingClient(delay: .zero),
            phone: Self.phone,
            selfieURL: selfieURL,
            voiceURL: Self.voiceURL,
            openMessages: { },
            onDismiss: { }
        )
        await vm.load()
        guard case .loaded(let card) = vm.loadState else {
            Issue.record("expected .loaded")
            return
        }
        // MockOnboardingClient echoes the selfieKey back as avatarURL so the
        // success screen can render the user's actual photo.
        #expect(card.avatarURL?.path == selfieURL.path)
    }
}
