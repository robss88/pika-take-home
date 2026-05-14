import SwiftUI

/// Title + subtitle block that anchors the voice-recording screen.
struct VoiceIntroHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("MAKE YOUR\nAI SELF SOUND\nLIKE YOU")
                .multilineTextAlignment(.center)
                .font(.semiDisplay(34))
                .foregroundStyle(Color.semiInk)
                .lineSpacing(2)

            Text("Read the text below to clone your\nvoice and create an\nAI Self that talks like you.")
                .multilineTextAlignment(.center)
                .font(.semiBody(13))
                .foregroundStyle(Color.semiInk.opacity(0.55))
        }
        .padding(.horizontal, 24)
    }
}
