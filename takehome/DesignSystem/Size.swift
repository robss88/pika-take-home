import CoreGraphics

/// Fixed size tokens for controls that have an intrinsic Figma height/width.
/// Variables (image dimensions, layout-driven heights) stay inline.
enum Size {
    /// Primary control height (CapsuleButton, PhoneNumberField).
    static let controlHeight: CGFloat = 56
    /// Compact control height (CountryPrefixBadge inside PhoneNumberField).
    static let controlHeightCompact: CGFloat = 44
    /// Back chip — Figma 48×48.
    static let backButton: CGFloat = 48
    /// OAuth circles on sign-in.
    static let oauthButton: CGFloat = 52
    /// Card slot — IDCardLoadStateView's reserved area for loading / loaded /
    /// error states. Same value used as both height (loading/error) and
    /// max-width (loaded), keeping the card's layout box stable.
    static let cardSlot: CGFloat = 280
    /// Primary tap target — shutter outer ring + voice review accept button.
    static let primaryAction: CGFloat = 86
    /// Top progress bar — 1pt continuous line.
    static let progressBarThickness: CGFloat = 1
    /// Standard border width.
    static let hairline: CGFloat = 1
}
