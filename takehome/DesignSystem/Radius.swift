import CoreGraphics

/// Corner-radius tokens. Pulled from the Figma source so individual components
/// don't drift away from the design system — change once, propagates.
enum Radius {
    /// Standard control corner (buttons, fields, cards). 18pt per Figma.
    static let control: CGFloat = 18
}
