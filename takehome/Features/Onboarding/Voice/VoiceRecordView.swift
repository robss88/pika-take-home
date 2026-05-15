import SwiftUI

struct VoiceRecordView: View {
    @State var viewModel: VoiceRecordViewModel

    var body: some View {
        ZStack {
            Color.semiOffWhite.ignoresSafeArea()

            VStack(spacing: 24) {
                ProgressDotsBar(step: 1, total: 3, onBack: viewModel.back)
                    .padding(.top, 8)

                VoiceIntroHeader()
                    .springAppear()

                Spacer(minLength: 0)

                ScriptHighlightView(
                    tokens: viewModel.tokens,
                    highlightedIndex: viewModel.highlightedIndex
                )
                .padding(.horizontal, 32)

                Spacer(minLength: 0)

                if let error = viewModel.error {
                    Text(error)
                        .font(.semiBody(12))
                        .foregroundStyle(.red.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                if viewModel.phase == .listening {
                    Text("Listening…")
                        .font(.semiBody(13))
                        .foregroundStyle(Color.semiInk.opacity(0.6))
                        .padding(.bottom, 4)
                        .transition(.opacity)
                }

                RecordControl(
                    phase: viewModel.phase,
                    onRecord: { Task { await viewModel.toggleRecord() } },
                    onReRecord: viewModel.reRecord,
                    onAccept: viewModel.accept,
                    onPlay: { Task { await viewModel.playBack() } }
                )
                .padding(.bottom, 36)
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
