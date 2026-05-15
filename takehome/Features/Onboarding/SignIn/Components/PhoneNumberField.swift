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
        HStack(spacing: Spacing.xxs) {
            CountryPrefixBadge(flag: countryFlag, dialCode: dialCode)

            // Placeholder floats centered behind the field; the TextField
            // itself is always left-aligned so the caret doesn't jump on the
            // first keystroke. Once `text` is non-empty the overlay drops out
            // and the typed text replaces it in the same leading position.
            ZStack {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.semiBody(17))
                        .foregroundStyle(Color.semiInk.opacity(0.35))
                        .frame(maxWidth: .infinity)
                        .allowsHitTesting(false)
                }
                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .font(.semiBody(17))
                    .foregroundStyle(Color.semiInk)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, Spacing.xs)
            }
            .frame(maxWidth: .infinity, minHeight: Size.controlHeightCompact)
        }
        .padding(.horizontal, Spacing.xs)
        .frame(height: Size.controlHeight)
        .background(Color.surfaceDark6, in: .rect(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .strokeBorder(Color.semiInk.opacity(0.04), lineWidth: Size.hairline)
        )
        .contentShape(.rect(cornerRadius: Radius.lg))
        .onTapGesture { focused = true }
    }
}

private struct CountryPrefixBadge: View {
    let flag: String
    let dialCode: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(flag).font(.system(size: 18))
            Text(dialCode)
                .font(.semiMonoRegular(16))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.horizontal, Spacing.sm)
        .frame(height: Size.controlHeightCompact)
        .background(Color.semiFieldFill.opacity(0.9), in: .rect(cornerRadius: Radius.lg - 4))
    }
}
