import CoreGraphics

/// Spacing tokens — t-shirt sizes matching Figma's `Spacing/*` scale. Every
/// padding, gap, and inset across the app routes through these so a Figma
/// scale change is a one-file edit. Half-step sizes (`smMd`, `mdLg`, `lgXl`,
/// `xlXxl`) cover the values that fall between the main t-shirt steps so we
/// don't end up with arithmetic like `Spacing.md - 2` peppered through views.
enum Spacing {
    static let xxs:   CGFloat = 4
    static let xs:    CGFloat = 6
    static let sm:    CGFloat = 8
    static let smMd:  CGFloat = 10
    static let md:    CGFloat = 12
    static let mdLg:  CGFloat = 14
    static let lg:    CGFloat = 16
    static let lgXl:  CGFloat = 20
    static let xl:    CGFloat = 24   // screen edge
    static let xlXxl: CGFloat = 28
    static let xxl:   CGFloat = 32   // wide edge
}
