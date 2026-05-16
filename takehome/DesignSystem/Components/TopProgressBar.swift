import SwiftUI

/// Top-of-screen progress indicator: back chip + a short continuous 1pt
/// progress line. Caller chooses the fill and track colors so this works
/// on both dark backdrops (camera) and light ones (voice).
struct TopProgressBar: View {
    /// Width of the progress track itself — kept short so the bar reads as
    /// a discrete indicator next to the back chip, not a full-screen rule.
    private static let trackWidth: CGFloat = 180

    let step: Int          // 0-based: how many steps are completed
    let total: Int
    var tint: Color = .semiPurpleDeep
    var track: Color = .semiPurpleSoft
    var arrowColor: Color = .semiInk
    let onBack: () -> Void

    var body: some View {
        ZStack {
            // Centered track — sits in the middle of the screen regardless
            // of the back button on the leading edge.
            ZStack(alignment: .leading) {
                Capsule().fill(track)
                Capsule()
                    .fill(tint)
                    .frame(width: Self.trackWidth * progress)
                    .animation(Motion.progressFill, value: step)
            }
            .frame(width: Self.trackWidth, height: Size.progressBarThickness)

            // Back chip overlaid at the leading edge.
            HStack {
                BackButton(arrowColor: arrowColor, action: onBack)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, Spacing.xl)
    }

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(min(step + 1, total)) / CGFloat(total)
    }
}
