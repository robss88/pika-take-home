import CoreGraphics

/// Corner-radius tokens, named to match Figma's `Radius/*` scale. Components
/// reference these so a Figma rename ripples through a single file.
enum Radius {
    /// Standard control corner (buttons, fields, back chip). 18pt per Figma.
    static let lg: CGFloat = 18
}
