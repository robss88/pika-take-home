import SwiftUI

struct IDCardView: View {
    let card: IDCard
    var localAvatarURL: URL? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                avatar
                    .frame(width: 130, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Spacer(minLength: 0)

                Image(systemName: "hare.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.semiInk)
                    .frame(width: 30, height: 30)
            }

            Text(card.name)
                .font(.semiDisplay(34))
                .foregroundStyle(Color.semiInk)
                .padding(.top, 12)

            Rectangle()
                .fill(Color.semiInk)
                .frame(height: Size.hairline)
                .padding(.vertical, Spacing.sm)

            HStack(alignment: .top, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 10) {
                    field(label: "BORN ON PIKA", value: card.bornOn)
                    field(label: "LOCATION", value: card.location)
                    field(label: "STATUS", value: card.status)
                    field(label: "FIND ME ON", value: card.findMeOn)
                }

                Spacer(minLength: 0)

                BarcodeView(payload: card.barcodePayload)
                    .frame(width: 80, height: 100)
                    .rotationEffect(.degrees(90))
                    .frame(width: 60, height: 110)
            }
        }
        .padding(Spacing.xl - 4)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.semiOffWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.semiInk.opacity(0.08), lineWidth: Size.hairline)
                )
                .shadow(color: Color.semiInk.opacity(0.08), radius: 18, x: 0, y: 8)
        )
    }

    private var avatar: some View {
        Group {
            if let url = localAvatarURL ?? card.avatarURL,
               url.isFileURL,
               let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if let url = card.avatarURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
    }

    private var avatarPlaceholder: some View {
        LinearGradient(
            colors: [Color.semiPurpleSoft, Color.semiCream],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(28)
                .foregroundStyle(Color.semiInk.opacity(0.25))
        )
    }

    private func field(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.semiMono(9))
                .foregroundStyle(Color.semiInk.opacity(0.5))
                .tracking(0.6)
            Text(value)
                .font(.semiMono(13))
                .foregroundStyle(Color.semiInk)
        }
    }
}
