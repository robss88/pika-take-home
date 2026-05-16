import Foundation

/// The success-screen payload returned by `POST /v1/ai-selves`. Every field
/// except `avatarURL` is pre-formatted on the backend so the client renders
/// it verbatim — no per-locale date / location formatting on the device.
nonisolated struct IDCard: Codable, Hashable, Sendable {
    let name: String
    /// Backend-formatted date string (e.g. `"FEB 11, 2026"`). Rendered as-is.
    let bornOn: String
    let location: String
    /// Free-form status text (today: `"ALIVE"`). Backend may expand this.
    let status: String
    /// Public handle URL displayed on the card (e.g. `"PIKA.ME/LUNA-SMITH"`).
    let findMeOn: String
    let avatarURL: URL?
    /// Raw string fed to `BarcodeView`'s Code128 generator.
    let barcodePayload: String

    /// Canned card used by `MockOnboardingClient` and as the fallback for
    /// previews. Field values mirror the design's reference frame.
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

/// Opaque bearer token returned by the auth endpoints. Persisted by the
/// caller (Keychain in production); this type carries no behavior of its own.
nonisolated struct AuthToken: Codable, Hashable, Sendable {
    let value: String
}
