import Foundation

/// A normalized phone number in E.164-ish form.
///
/// `national` excludes the country dial prefix. Combined with `countryCode`
/// it forms the full E.164 (e.g. "+1" + "2025550123").
nonisolated struct E164: Hashable, Sendable {
    let countryCode: String   // e.g. "1"
    let national: String      // e.g. "2025550123"

    var e164String: String { "+\(countryCode)\(national)" }
}

protocol PhoneNumberFormatter: Sendable {
    /// Format-as-you-type for the visible field text.
    nonisolated func formatPartial(_ raw: String) -> String

    /// Validate & normalize. Returns nil if the input isn't a valid number.
    nonisolated func parse(_ raw: String) -> E164?
}

/// Minimal US-only formatter.
///
/// In production we would back this with libphonenumber (PhoneNumberKit) for
/// proper multi-locale support. The seam is here: swap the conforming type
/// in `AppEnvironment.live` without touching any call site.
nonisolated struct USPhoneNumberFormatter: PhoneNumberFormatter {
    func formatPartial(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber).prefix(10)
        switch digits.count {
        case 0:
            return ""
        case 1...3:
            return "(\(digits)"
        case 4...6:
            let area = digits.prefix(3)
            let mid = digits.dropFirst(3)
            return "(\(area)) \(mid)"
        default:
            let area = digits.prefix(3)
            let mid = digits.dropFirst(3).prefix(3)
            let last = digits.dropFirst(6)
            return "(\(area)) \(mid)-\(last)"
        }
    }

    func parse(_ raw: String) -> E164? {
        let digits = raw.filter(\.isNumber)
        guard digits.count == 10 else { return nil }
        guard let first = digits.first, first != "0", first != "1" else { return nil }
        return E164(countryCode: "1", national: digits)
    }
}
