import SwiftUI

/// Top-of-screen progress indicator: back chip + a single continuous 1pt
/// progress line. Caller chooses the fill and track colors so this works
/// on both dark backdrops (camera) and light ones (voice).
struct TopProgressBar: View {
    let step: Int          // 0-based: how many steps are completed
    let total: Int
    var tint: Color = .semiPurpleDeep
    var track: Color = .semiPurpleSoft
    var arrowColor: Color = .semiInk
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: Spacing.lg) {
            BackButton(arrowColor: arrowColor, action: onBack)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(track)
                    Capsule()
                        .fill(tint)
                        .frame(width: geo.size.width * progress)
                        .animation(Motion.progressFill, value: step)
                }
            }
            .frame(height: Size.progressBarThickness)
        }
        .padding(.horizontal, Spacing.xl)
    }

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(min(step + 1, total)) / CGFloat(total)
    }
}
