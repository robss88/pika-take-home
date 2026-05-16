import SwiftUI

extension View {
    /// Applies a small slide-up + fade-in spring on appear. Stack multiple
    /// instances with increasing `delay` to stagger entrance.
    func springAppear(delay: Double = 0, distance: CGFloat = 14) -> some View {
        modifier(SpringAppearModifier(delay: delay, distance: distance))
    }
}

private struct SpringAppearModifier: ViewModifier {
    let delay: Double
    let distance: CGFloat
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : distance)
            .onAppear {
                withAnimation(Motion.entrance.delay(delay)) {
                    visible = true
                }
            }
    }
}
