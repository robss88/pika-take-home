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
    /// Maximum number of significant digits accepted, tied to the country.
    /// Extra keystrokes are rejected before they reach the binding so the
    /// user never sees an 11th digit flash on screen. US is 10.
    var maxDigits: Int = 10

    /// Mirror of `text` that the TextField writes into directly. The two
    /// stay in sync via the `onChange` pair below. This keeps the
    /// caller-side formatter (set via `text`'s binding) from racing with
    /// the TextField's internal storage mid-edit, which is the SwiftUI
    /// footgun for format-as-you-type.
    @State private var localText: String = ""

    var body: some View {
        ZStack {
            HStack(spacing: Spacing.xxs) {
                CountryPrefixBadge(flag: countryFlag, dialCode: dialCode)

                TextField("", text: $localText)
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
        .animation(Motion.fade, value: text.isEmpty)
        .onAppear { localText = text }
        .onChange(of: localText) { _, new in
            // Hard-cap by country: drop the keystroke before it propagates.
            if new.count(where: \.isNumber) > maxDigits {
                localText = text
                return
            }
            // Push raw edits up to the caller's formatter.
            if new != text { text = new }
        }
        .onChange(of: text) { _, new in
            // Pull the formatted result back into the field.
            if new != localText { localText = new }
        }
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
