import SwiftUI

/// Phone-number capsule field with a country prefix.
///
/// Pure presentation: the caller binds `text` and is responsible for any
/// format-as-you-type behavior (done in `SignInViewModel.updatePhone`).
struct PhoneNumberField: View {
    @Binding var text: String
    @FocusState.Binding var focused: Bool
    var countryFlag: String = "🇺🇸"
    var dialCode: String = "+1"
    var placeholder: String = "Phone number"

    var body: some View {
        HStack(spacing: 4) {
            CountryPrefixBadge(flag: countryFlag, dialCode: dialCode)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundStyle(Color.semiInk.opacity(0.35)),
            )
            .keyboardType(.numberPad)
            .focused($focused)
            .font(.semiBody(16))
            .foregroundStyle(Color.semiInk)
            .frame(maxWidth: .infinity, minHeight: 44)
            .multilineTextAlignment(.leading)
            
        }
        .padding(.horizontal, 6)
        .frame(height: 56)
        .background(Color.semiFieldFill, in: .rect(cornerRadius: Radius.control))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control)
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
        .padding(.horizontal, 10)
        .frame(height: 44)
        .background(Color.semiFieldFill.opacity(0.9), in: .rect(cornerRadius: Radius.control - 4))
    }
}
