import CoreGraphics

/// Spacing tokens — t-shirt sizes matching Figma's `Spacing/*` scale. Every
/// padding, gap, and inset across the app routes through these so a Figma
/// scale change is a one-file edit.
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 6
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 24   // screen edge
    static let xxl: CGFloat = 32   // wide edge (camera blockers, voice script)
}
