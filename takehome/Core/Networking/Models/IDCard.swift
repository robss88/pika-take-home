import Foundation

nonisolated struct IDCard: Codable, Hashable, Sendable {
    let name: String
    let bornOn: String          // pre-formatted by the backend (e.g., "FEB 11, 2026")
    let location: String
    let status: String          // "ALIVE" etc.
    let findMeOn: String        // "PIKA.ME/LUNA-SMITH"
    let avatarURL: URL?
    let barcodePayload: String  // raw string used to render the Code128

    static let canned = IDCard(
        name: "SEMI",
        bornOn: "FEB 11, 2026",
        location: "SAN FRANCISCO, CA",
        status: "ALIVE",
        findMeOn: "PIKA.ME/LUNA-SMITH",
        avatarURL: nil,
        barcodePayload: "SEMI-LUNA-SMITH-0001"
    )
}

nonisolated struct AuthToken: Codable, Hashable, Sendable {
    let value: String
}
