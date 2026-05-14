import SwiftUI

struct RecordControl: View {
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
                        .frame(width: 92, height: 92)
                        .scaleEffect(pulse)
                        .opacity(pulseOpacity)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: phase
                        )
                    singleButton(filled: true, icon: nil, dotShown: false, action: onRecord)
                }
                .transition(.opacity)
            case .review, .playing:
                reviewRow
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: phase)
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
                    .frame(width: 78, height: 78)
                    .matchedGeometryEffect(id: "recordCore", in: morph)

                if dotShown {
                    Circle()
                        .fill(Color.semiInk)
                        .frame(width: 22, height: 22)
                }
                if filled {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.semiPurpleDeep)
                        .frame(width: 26, height: 26)
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
        HStack(spacing: 28) {
            CircleIconButton(
                systemName: "arrow.triangle.2.circlepath",
                size: 52,
                tint: .semiInk,
                fill: Color.semiFieldFill,
                action: onReRecord
            )

            Button(action: onAccept) {
                ZStack {
                    Circle()
                        .fill(Color.semiLavender)
                        .frame(width: 86, height: 86)
                        .matchedGeometryEffect(id: "recordCore", in: morph)
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.semiInk)
                }
            }
            .buttonStyle(.plain)

            CircleIconButton(
                systemName: phase == .playing ? "stop.fill" : "play.fill",
                size: 52,
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
