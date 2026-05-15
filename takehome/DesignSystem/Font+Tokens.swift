import SwiftUI

extension Font {
    // MARK: - Display / titles (Telka Extended)

    /// Hero headlines — Telka Extended Black.
    static func semiDisplay(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedBlack", size: size)
    }
    /// Section titles, ID card name, primary button labels — Telka Extended Bold.
    static func semiTitle(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedBold", size: size)
    }
    /// Sub-titles / display-medium weight — Telka Extended Medium.
    static func semiDisplayMedium(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedMedium", size: size)
    }
    /// Largest display weight — Telka Extended Super (for marquee moments).
    static func semiDisplaySuper(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedSuper", size: size)
    }
    /// Light display variant for subdued large copy.
    static func semiDisplayLight(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedLight", size: size)
    }
    /// Regular Telka Extended for caption-style display copy.
    static func semiDisplayRegular(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedRegular", size: size)
    }

    // MARK: - Body copy (Telka proportional)

    /// Body copy, supporting text — Telka Regular. Telka is the
    /// design-system primary, so anything that isn't tabular data uses this.
    static func semiBody(_ size: CGFloat) -> Font {
        .custom("Telka-Regular", size: size)
    }
    /// Slightly emphasized body — Telka Medium.
    static func semiBodyMedium(_ size: CGFloat) -> Font {
        .custom("Telka-Medium", size: size)
    }

    // MARK: - Tabular / accent (SpaceMono + BPdotsVertical)

    /// Field labels, codes, ID-card tabular data — SpaceMono Bold.
    static func semiMono(_ size: CGFloat) -> Font {
        .custom("SpaceMono-Bold", size: size)
    }
    /// Lighter monospaced — SpaceMono Regular.
    static func semiMonoRegular(_ size: CGFloat) -> Font {
        .custom("SpaceMono-Regular", size: size)
    }
    /// Accent / barcode-strip ornamentation — BPdotsVertical.
    static func semiAccent(_ size: CGFloat) -> Font {
        .custom("BPdotsVertical", size: size)
    }
    /// Heavier accent — BPdotsVertical Bold.
    static func semiAccentBold(_ size: CGFloat) -> Font {
        .custom("BPdotsVertical-Bold", size: size)
    }
}
