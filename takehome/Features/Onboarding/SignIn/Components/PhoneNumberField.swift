import SwiftUI

/// Phone-number capsule field with a country prefix.
///
/// Pure presentation: the caller binds `text` and is responsible for any
/// format-as-you-type behavior (done in `SignInViewModel.updatePhone`).
struct PhoneNumberField: View {
    @Binding var text: String
    var countryFlag: String = "🇺🇸"
    var dialCode: String = "+1"
    var placeholder: String = "Phone number"

    var body: some View {
        HStack(spacing: 12) {
            CountryPrefixBadge(flag: countryFlag, dialCode: dialCode)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundStyle(Color.semiInk.opacity(0.35))
            )
            .keyboardType(.numberPad)
            .font(.semiBody(16))
            .foregroundStyle(Color.semiInk)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .padding(.horizontal, 8)
        .frame(height: 56)
        .background(Color.semiFieldFill, in: .capsule)
        .overlay(
            Capsule()
                .strokeBorder(Color.semiInk.opacity(0.04), lineWidth: 1)
        )
    }
}

private struct CountryPrefixBadge: View {
    let flag: String
    let dialCode: String

    var body: some View {
        HStack(spacing: 6) {
            Text(flag).font(.system(size: 18))
            Text(dialCode)
                .font(.semiMono(14))
                .foregroundStyle(Color.semiInk.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(Color.semiFieldFill.opacity(0.9), in: .capsule)
    }
}
