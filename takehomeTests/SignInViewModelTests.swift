import Foundation
import Testing
@testable import takehome

@MainActor
@Suite("SignInViewModel")
struct SignInViewModelTests {
    @Test func valid_phone_advances_on_continue() async {
        var capturedPhone: E164?
        let vm = SignInViewModel(
            auth: MockAuthService(delay: .zero),
            phoneFormatter: USPhoneNumberFormatter(),
            onSignedIn: { capturedPhone = $0 }
        )

        vm.updatePhone("2025550123")
        #expect(vm.isValid)
        await vm.submit()

        #expect(capturedPhone?.national == "2025550123")
        #expect(vm.error == nil)
        #expect(vm.isSubmitting == false)
    }

    @Test func failed_signIn_surfaces_error_and_does_not_advance() async {
        var didAdvance = false
        let vm = SignInViewModel(
            auth: MockAuthService(shouldFail: true, delay: .zero),
            phoneFormatter: USPhoneNumberFormatter(),
            onSignedIn: { _ in didAdvance = true }
        )

        vm.updatePhone("2025550123")
        await vm.submit()

        #expect(didAdvance == false)
        #expect(vm.error != nil)
    }

    @Test func submit_is_noop_when_phone_invalid() async {
        var didAdvance = false
        let vm = SignInViewModel(
            auth: MockAuthService(delay: .zero),
            phoneFormatter: USPhoneNumberFormatter(),
            onSignedIn: { _ in didAdvance = true }
        )

        vm.updatePhone("123")
        #expect(vm.isValid == false)
        await vm.submit()
        #expect(didAdvance == false)
    }

    @Test func updatePhone_runs_text_through_the_formatter() {
        let vm = SignInViewModel(
            auth: MockAuthService(delay: .zero),
            phoneFormatter: USPhoneNumberFormatter(),
            onSignedIn: { _ in }
        )
        vm.updatePhone("2025550123")
        #expect(vm.phoneText == "(202) 555-0123")
    }

    @Test func parsedPhone_returns_E164_after_valid_input() {
        let vm = SignInViewModel(
            auth: MockAuthService(delay: .zero),
            phoneFormatter: USPhoneNumberFormatter(),
            onSignedIn: { _ in }
        )
        vm.updatePhone("2025550123")
        #expect(vm.parsedPhone?.e164String == "+12025550123")
    }

    @Test func submitting_state_clears_after_failure() async {
        let vm = SignInViewModel(
            auth: MockAuthService(shouldFail: true, delay: .zero),
            phoneFormatter: USPhoneNumberFormatter(),
            onSignedIn: { _ in }
        )
        vm.updatePhone("2025550123")
        await vm.submit()
        #expect(vm.isSubmitting == false)
    }
}
