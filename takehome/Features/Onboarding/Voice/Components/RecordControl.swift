import SwiftUI

struct RecordControl: View {
    // Component-internal morph constants. Kept private so they don't pollute
    // the shared DS namespace — they only make sense in this control.
    private static let pulseRingSize: CGFloat = 92
    private static let coreSize: CGFloat = 78
    private static let idleDotSize: CGFloat = 22
    private static let stopSquareSize: CGFloat = 26
    private static let stopSquareCorner: CGFloat = 6

    let phase: VoiceRecordViewModel.Phase
    let onRecord: () -> Void
    let onReRecord: () -> Void
    let onAccept: () -> Void
    let onPlay: () -> Void

    @Namespace private var morph

    var body: some View {
        ZStack {
            switch phase {
            case .idle:
                singleButton(filled: false, icon: nil, dotShown: true, action: onRecord)
                    .transition(.scale.combined(with: .opacity))
            case .listening:
                ZStack {
                    Circle()
                        .stroke(Color.semiPurpleSoft, lineWidth: 3)
                        .frame(width: Self.pulseRingSize, height: Self.pulseRingSize)
                        .scaleEffect(pulse)
                        .opacity(pulseOpacity)
                        .animation(Motion.pulse, value: phase)
                    singleButton(filled: true, icon: nil, dotShown: false, action: onRecord)
                }
                .transition(.opacity)
            case .review, .playing:
                reviewRow
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(Motion.recordMorph, value: phase)
    }

    private func singleButton(
        filled: Bool,
        icon: String?,
        dotShown: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.semiLavender)
                    .frame(width: Self.coreSize, height: Self.coreSize)
                    .matchedGeometryEffect(id: "recordCore", in: morph)

                if dotShown {
                    Circle()
                        .fill(Color.semiInk)
                        .frame(width: Self.idleDotSize, height: Self.idleDotSize)
                }
                if filled {
                    RoundedRectangle(cornerRadius: Self.stopSquareCorner, style: .continuous)
                        .fill(Color.semiPurpleDeep)
                        .frame(width: Self.stopSquareSize, height: Self.stopSquareSize)
                }
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.semiInk)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var reviewRow: some View {
        HStack(spacing: Spacing.xlXxl) {
            CircleIconButton(
                systemName: "arrow.triangle.2.circlepath",
                size: Size.oauthButton,
                tint: .semiInk,
                fill: Color.semiFieldFill,
                action: onReRecord
            )

            Button(action: onAccept) {
                ZStack {
                    Circle()
                        .fill(Color.semiLavender)
                        .frame(width: Size.primaryAction, height: Size.primaryAction)
                        .matchedGeometryEffect(id: "recordCore", in: morph)
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.semiInk)
                }
            }
            .buttonStyle(.plain)

            CircleIconButton(
                systemName: phase == .playing ? "stop.fill" : "play.fill",
                size: Size.oauthButton,
                tint: .semiInk,
                fill: Color.semiFieldFill,
                action: onPlay
            )
        }
    }

    @State private var pulseFlip = false
    private var pulse: CGFloat { 1.0 + (pulseFlip ? 0.05 : -0.05) }
    private var pulseOpacity: Double { pulseFlip ? 0.55 : 0.35 }
}
