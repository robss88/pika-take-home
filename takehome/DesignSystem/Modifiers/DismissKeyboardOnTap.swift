import SwiftUI
import UIKit

extension View {
    /// Resigns first responder when the user taps anywhere on the view that
    /// isn't already an interactive subview. Uses `simultaneousGesture` so
    /// taps on buttons / text fields still register normally — only the
    /// "tapped empty space" case dismisses the keyboard.
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
    }
}
