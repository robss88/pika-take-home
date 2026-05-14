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
}
