import Foundation

/// Single source of truth for backend paths. Live clients, mock seeds, and
/// tests all reference these constants so a path rename is a one-file change
/// and there are no string-literal drift risks between real and stub layers.
nonisolated enum APIPaths {
    /// Sign-in endpoint. All auth methods (phone/Google/email) POST here today
    /// pending backend clarification — see "Open questions for the backend"
    /// in the README.
    static let signIn = "/v1/auth/phone"

    /// AI-self creation: selfie + voice keys → IDCard.
    static let createAISelf = "/v1/ai-selves"
}
