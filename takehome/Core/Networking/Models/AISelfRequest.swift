import Foundation

nonisolated struct AISelfRequest: Codable, Hashable, Sendable {
    let phone: String
    let selfieKey: String   // server-side key/path after upload
    let voiceKey: String
}

nonisolated struct AuthRequest: Codable, Hashable, Sendable {
    nonisolated enum Method: String, Codable, Sendable { case phone, google, email }
    let method: Method
    let phone: String?
}
