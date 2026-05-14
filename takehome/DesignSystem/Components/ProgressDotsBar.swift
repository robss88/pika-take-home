import SwiftUI

/// The back-chevron + segmented progress bar that sits at the top of every
/// flow screen after sign-in. Three segments here (camera, voice, review).
struct ProgressDotsBar: View {
    let step: Int          // 0-based: which segment is "filled"
    let total: Int
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            CircleIconButton(systemName: "chevron.left", size: 40, action: onBack)

            HStack(spacing: 8) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index <= step ? Color.semiPurpleDeep : Color.semiPurpleSoft)
                        .frame(height: 4)
                        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
