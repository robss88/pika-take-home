import SwiftUI

/// Typography tokens grouped by typeface family. Three families are in use:
/// Telka Extended (display + titles), Telka (proportional body), SpaceMono
/// (tabular data). Each token takes a size so the same family/weight pairing
/// works across multiple sizes without proliferating named tokens.
extension Font {
    // MARK: - Display / titles (Telka Extended)

    /// Hero headlines — Telka Extended Black.
    static func semiDisplay(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedBlack", size: size)
    }
    /// Section titles, ID-card name — Telka Extended Bold.
    static func semiTitle(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedBold", size: size)
    }

    // MARK: - Body copy (Telka proportional)

    /// Body copy, supporting text — Telka Regular. Telka is the
    /// design-system primary, so anything that isn't tabular data uses this.
    static func semiBody(_ size: CGFloat) -> Font {
        .custom("Telka-Regular", size: size)
    }
    /// Slightly emphasized body — Telka Medium. Primary-button labels.
    static func semiBodyMedium(_ size: CGFloat) -> Font {
        .custom("Telka-Medium", size: size)
    }

    // MARK: - Tabular (SpaceMono)

    /// Field labels, ID-card tabular data — SpaceMono Bold.
    static func semiMono(_ size: CGFloat) -> Font {
        .custom("SpaceMono-Bold", size: size)
    }
    /// Lighter monospaced — SpaceMono Regular. Country-code badge.
    static func semiMonoRegular(_ size: CGFloat) -> Font {
        .custom("SpaceMono-Regular", size: size)
    }
}
