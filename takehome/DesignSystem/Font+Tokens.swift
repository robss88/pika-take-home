import SwiftUI

extension Font {
    /// Hero headlines — Telka Extended Black.
    static func semiDisplay(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedBlack", size: size)
    }
    /// Section titles, ID card name — Telka Extended Bold.
    static func semiTitle(_ size: CGFloat) -> Font {
        .custom("Telka-ExtendedBold", size: size)
    }
    /// Body copy, form text — SpaceMono Regular.
    static func semiBody(_ size: CGFloat) -> Font {
        .custom("SpaceMono-Regular", size: size)
    }
    /// Field labels, monospaced data — SpaceMono Bold.
    static func semiMono(_ size: CGFloat) -> Font {
        .custom("SpaceMono-Bold", size: size)
    }
    /// Accent / barcode-strip ornamentation — BPdotsVertical.
    static func semiAccent(_ size: CGFloat) -> Font {
        .custom("BPdotsVertical", size: size)
    }
}
