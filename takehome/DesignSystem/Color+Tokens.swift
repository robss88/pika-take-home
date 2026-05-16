import SwiftUI

extension Color {
    // MARK: - Brand surfaces

    /// Page background — warm off-white that anchors the brand palette.
    static let semiOffWhite = Color(red: 0.957, green: 0.945, blue: 0.918)
    /// Soft lavender used on the primary "Continue" / record / accept buttons.
    static let semiLavender = Color(red: 0.745, green: 0.706, blue: 1.0)
    /// Deeper purple used for highlighted script text and primary accents.
    static let semiPurpleDeep = Color(red: 0.498, green: 0.420, blue: 0.965)
    /// Pale lavender for the un-spoken script state and subtle accents.
    static let semiPurpleSoft = Color(red: 0.831, green: 0.804, blue: 0.965)
    /// Near-black for hero CTAs, body, and the ID-card stroke.
    static let semiInk = Color(red: 13/255, green: 13/255, blue: 13/255)
    /// Slightly warm secondary background (Share ID Card CTA).
    static let semiCream = Color(red: 0.929, green: 0.910, blue: 0.875)
    /// Subdued field background.
    static let semiFieldFill = Color(red: 0.937, green: 0.925, blue: 0.910)
    /// Warm peach-cream — bottom stop of the Success/Voice background
    /// gradient. Matches the screenshot's subtle pink fade.
    static let semiBlush = Color(red: 0.957, green: 0.894, blue: 0.871)

    // MARK: - Semantic overlays (Figma `surface-dark-*` + text scale)

    /// 5% dark surface — Figma `surface-dark-6`. Back-button chip, OAuth tile.
    static let surfaceDark6 = semiInk.opacity(0.05)
    /// Secondary text — ~60% ink, used on labels that recede from body copy.
    static let textSecondary = semiInk.opacity(0.6)
    /// Tertiary text — ~70% ink, used on subdued labels (e.g. badge dial code).
    static let textTertiary = semiInk.opacity(0.7)
}
