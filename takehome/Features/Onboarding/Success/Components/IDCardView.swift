import SwiftUI

struct IDCardView: View {
    let card: IDCard
    var localAvatarURL: URL? = nil

    // IDCard-internal layout constants. Co-located on the view because the
    // card is the only consumer; they're not part of the shared DS scale.
    private static let avatarSize = CGSize(width: 130, height: 160)
    private static let barcodeSize = CGSize(width: 130, height: 38)
    private static let rabbitSize = CGSize(width: 34, height: 26)
    private static let cardCornerRadius: CGFloat = 20
    private static let avatarCornerRadius: CGFloat = 6
    private static let cardShadowRadius: CGFloat = 18

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: Spacing.mdLg) {
                avatar
                    .frame(width: Self.avatarSize.width, height: Self.avatarSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: Self.avatarCornerRadius))

                Spacer(minLength: 0)

                Image("RabbitIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.semiInk)
                    .frame(width: Self.rabbitSize.width, height: Self.rabbitSize.height)
            }

            Text(card.name)
                .font(.semiDisplay(34))
                .foregroundStyle(Color.semiInk)
                .padding(.top, Spacing.md)

            Rectangle()
                .fill(Color.semiInk)
                .frame(height: Size.hairline)
                .padding(.vertical, Spacing.sm)

            HStack(alignment: .top, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.smMd) {
                    field(label: "BORN ON PIKA", value: card.bornOn)
                    field(label: "LOCATION", value: card.location)
                    field(label: "STATUS", value: card.status)
                    field(label: "FIND ME ON", value: card.findMeOn)
                }

                Spacer(minLength: 0)

                BarcodeView(payload: card.barcodePayload)
                    .frame(width: Self.barcodeSize.width, height: Self.barcodeSize.height)
                    .rotationEffect(.degrees(90))
                    .frame(width: Self.barcodeSize.height, height: Self.barcodeSize.width)
                    .blendMode(.multiply)   // drops the generator's white background
                    .padding(.trailing, Spacing.xxs)
            }
        }
        .padding(Spacing.lgXl)
        .background(
            RoundedRectangle(cornerRadius: Self.cardCornerRadius, style: .continuous)
                .fill(Color.semiOffWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: Self.cardCornerRadius, style: .continuous)
                        .strokeBorder(Color.semiInk.opacity(0.08), lineWidth: Size.hairline)
                )
                .shadow(color: Color.semiInk.opacity(0.08), radius: Self.cardShadowRadius, x: 0, y: 8)
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
                .padding(Spacing.xlXxl)
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
