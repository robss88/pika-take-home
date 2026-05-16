import Foundation

/// `POST /v1/ai-selves` body. `selfieKey` and `voiceKey` reference media that
/// has already been uploaded via `MediaUploader`; this endpoint composes the
/// AI Self from those keys rather than accepting raw media itself.
nonisolated struct AISelfRequest: Codable, Hashable, Sendable {
    let phone: String
    let selfieKey: String
    let voiceKey: String
}

/// `POST /v1/auth/phone` body. The same endpoint handles every sign-in flow
/// today; `method` discriminates phone vs OAuth (Google / email). `phone` is
/// nil for OAuth methods — the backend looks the user up by token instead.
nonisolated struct AuthRequest: Codable, Hashable, Sendable {
    nonisolated enum Method: String, Codable, Sendable { case phone, google, email }
    let method: Method
    let phone: String?
}
