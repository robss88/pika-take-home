import CoreText
import Foundation
import os
import UIKit

/// Register all bundled OTF/TTF font files with CoreText at launch.
///
/// We do this in code rather than via `UIAppFonts` in Info.plist because the
/// auto-generated Info.plist (`GENERATE_INFOPLIST_FILE=YES`) doesn't honor
/// arbitrary `INFOPLIST_KEY_UIAppFonts` array values — and adding a custom
/// Info.plist file just for that would be more friction than this helper.
enum FontRegistration {
    private static let logger = Logger(subsystem: "com.pika.takehome", category: "fonts")

    static func registerBundledFonts() {
        let bundle = Bundle.main
        let exts = ["otf", "ttf"]
        for ext in exts {
            guard let urls = bundle.urls(forResourcesWithExtension: ext, subdirectory: nil) else {
                continue
            }
            for url in urls {
                var error: Unmanaged<CFError>?
                let ok = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
                if !ok {
                    let cfErr = error?.takeRetainedValue()
                    let message = cfErr.map { String(describing: $0) } ?? "unknown"
                    // Re-registration on a hot-reload is harmless and common in previews.
                    logger.debug("Font registration skipped for \(url.lastPathComponent): \(message)")
                }
            }
        }
        #if DEBUG
        for family in UIFont.familyNames.sorted() where family.lowercased().contains("telka")
            || family.lowercased().contains("space")
            || family.lowercased().contains("bpdots") {
            logger.debug("Family: \(family) -> \(UIFont.fontNames(forFamilyName: family))")
        }
        #endif
    }
}
