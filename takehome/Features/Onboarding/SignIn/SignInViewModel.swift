import Foundation
import Observation

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

    var parsedPhone: E164? { phoneFormatter.parse(phoneText) }
    var isValid: Bool { parsedPhone != nil }

    func updatePhone(_ raw: String) {
        phoneText = phoneFormatter.formatPartial(raw)
    }

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
