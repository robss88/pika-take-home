import SwiftUI

struct VoiceRecordView: View {
    @State var viewModel: VoiceRecordViewModel

    var body: some View {
        ZStack {
            Color.semiOffWhite.ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                TopProgressBar(step: 1, total: 3, onBack: viewModel.back)
                    .padding(.top, Spacing.sm)

                VoiceIntroHeader()
                    .springAppear()

                Spacer(minLength: 0)

                ScriptHighlightView(
                    tokens: viewModel.tokens,
                    highlightedIndex: viewModel.highlightedIndex
                )
                .padding(.horizontal, Spacing.xxl)

                Spacer(minLength: 0)

                if let error = viewModel.error {
                    Text(error)
                        .font(.semiBody(12))
                        .foregroundStyle(.red.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }

                if viewModel.phase == .listening {
                    Text("Listening…")
                        .font(.semiBody(13))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.bottom, Spacing.xxs)
                        .transition(.opacity)
                }

                RecordControl(
                    phase: viewModel.phase,
                    onRecord: { Task { await viewModel.toggleRecord() } },
                    onReRecord: viewModel.reRecord,
                    onAccept: viewModel.accept,
                    onPlay: { Task { await viewModel.playBack() } }
                )
                .padding(.bottom, Spacing.xxl)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.phase)
    }
}

#Preview {
    VoiceRecordView(
        viewModel: VoiceRecordViewModel(
            recorder: AppEnvironment.preview.audioRecorderFactory(),
            aligner: AppEnvironment.preview.speechAlignerFactory(),
            onAccepted: { _ in },
            onBack: { }
        )
    )
    .applyAppEnvironment(.preview)
}
