import Foundation
import Observation

/// Drives the sign-in screen. Owns the format-as-you-type phone state,
/// validates it via the injected `PhoneNumberFormatter`, and runs the
/// auth call against the injected `AuthService`. The `onSignedIn` callback
/// hands control back to the coordinator with a parsed `E164` so the next
/// step has a typed phone payload to thread forward.
@Observable
final class SignInViewModel {
    var phoneText: String = ""
    var isSubmitting: Bool = false
    var error: String? = nil

    private let auth: any AuthService
    private let phoneFormatter: any PhoneNumberFormatter
    private let onSignedIn: (E164) -> Void

    init(
        auth: any AuthService,
        phoneFormatter: any PhoneNumberFormatter,
        onSignedIn: @escaping (E164) -> Void
    ) {
        self.auth = auth
        self.phoneFormatter = phoneFormatter
        self.onSignedIn = onSignedIn
    }

    /// The parsed E.164 form of `phoneText`, or `nil` if the input isn't
    /// a complete, valid phone number for the active locale.
    var parsedPhone: E164? { phoneFormatter.parse(phoneText) }

    /// Drives the Continue button's enabled state.
    var isValid: Bool { parsedPhone != nil }

    /// Format-as-you-type entry point. Whatever the field hands us, we
    /// run through the formatter and write the result back to `phoneText`.
    func updatePhone(_ raw: String) {
        phoneText = phoneFormatter.formatPartial(raw)
    }

    /// Phone sign-in: validates, calls `auth.signIn(.phone(...))`, and
    /// propagates success to the coordinator. No-op when the phone hasn't
    /// parsed cleanly or while a submission is already in flight.
    func submit() async {
        guard let phone = parsedPhone, !isSubmitting else { return }
        isSubmitting = true
        error = nil
        defer { isSubmitting = false }
        do {
            _ = try await auth.signIn(.phone(phone))
            onSignedIn(phone)
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    /// Sign in via Google / email. OAuth identifies the user but doesn't
    /// give us a phone, so we synthesize an empty `E164` placeholder to
    /// satisfy the typed route payload. A real backend would either return
    /// a phone-on-file or surface a follow-up screen to collect one — the
    /// seam stays the same.
    func oauth(_ method: AuthMethod) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        error = nil
        defer { isSubmitting = false }
        do {
            _ = try await auth.signIn(method)
            onSignedIn(E164(countryCode: "1", national: "0000000000"))
        } catch {
            self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
