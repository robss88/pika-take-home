import SwiftUI

extension View {
    /// Slides the view up by `distance` and fades it in with `Motion.entrance`
    /// the first time it appears. Stack multiple instances with increasing
    /// `delay` on sibling views to cascade their entrances.
    ///
    /// - Parameters:
    ///   - delay: Seconds before the animation fires (used for staggering).
    ///   - distance: Pixels below the resting position to start the slide.
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
