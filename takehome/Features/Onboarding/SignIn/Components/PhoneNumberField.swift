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
        ZStack {
            HStack(spacing: Spacing.xxs) {
                CountryPrefixBadge(flag: countryFlag, dialCode: dialCode)

                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .focused($focused)
                    .font(.semiBody(17))
                    .foregroundStyle(Color.semiInk)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, Spacing.xs)
            }

            // Placeholder floats centered across the *whole* field — not just
            // the TextField column — so it reads as the field's resting label.
            // The TextField stays left-aligned so the caret doesn't jump on
            // the first keystroke; the placeholder fades out as text appears.
            if text.isEmpty {
                Text(placeholder)
                    .font(.semiBody(17))
                    .foregroundStyle(Color.semiInk.opacity(0.35))
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
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
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
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
