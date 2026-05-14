import Foundation
import Testing
@testable import takehome

@MainActor
@Suite("SuccessViewModel")
struct SuccessViewModelTests {
    private static let selfieURL = URL(fileURLWithPath: "/tmp/test-selfie.jpg")
    private static let voiceURL  = URL(fileURLWithPath: "/tmp/test-voice.m4a")

    @Test func loaded_state_after_successful_creation() async {
        let vm = SuccessViewModel(
            client: MockOnboardingClient(delay: .zero),
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
}
