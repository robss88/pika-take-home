import Foundation
import Testing
@testable import takehome

/// These tests prove the *live* service implementations route through
/// `APIClient` to the right endpoints — the production-side seam works
/// today; flipping `AppEnvironment.resolved()` to `.live` is the only
/// change needed when the backend lands.
@Suite("Live services via APIClient")
struct LiveServiceTests {
    @Test func liveAuthService_phone_signIn_posts_to_v1_auth_phone() async throws {
        let api = MockAPIClient(artificialDelay: .zero)
        api.stubJSON(.post, "/v1/auth/phone", with: AuthToken(value: "ok-token"))
        let auth = LiveAuthService(api: api)

        let token = try await auth.signIn(.phone(E164(countryCode: "1", national: "2025550123")))
        #expect(token == AuthToken(value: "ok-token"))
        #expect(api.recordedCalls() == ["POST /v1/auth/phone"])
    }

    @Test func liveAuthService_google_method_uses_same_endpoint() async throws {
        let api = MockAPIClient(artificialDelay: .zero)
        api.stubJSON(.post, "/v1/auth/phone", with: AuthToken(value: "g-token"))
        let auth = LiveAuthService(api: api)

        // The phone endpoint name is the current stub; both phone and oauth
        // paths run through it. The test pins the recorded call so a future
        // routing change is caught here, not in production.
        let token = try await auth.signIn(.google)
        #expect(token.value == "g-token")
        #expect(api.recordedCalls() == ["POST /v1/auth/phone"])
    }

    @Test func liveAuthService_surfaces_api_failure() async {
        let api = MockAPIClient(artificialDelay: .zero)
        api.stub(.post, "/v1/auth/phone", thenThrowing: .status(401, Data()))
        let auth = LiveAuthService(api: api)

        await #expect(throws: APIError.self) {
            _ = try await auth.signIn(.phone(E164(countryCode: "1", national: "2025550123")))
        }
    }

    @Test func liveOnboardingClient_posts_to_v1_ai_selves() async throws {
        let api = MockAPIClient(artificialDelay: .zero)
        api.stubJSON(.post, "/v1/ai-selves", with: IDCard.canned)
        let client = LiveOnboardingClient(api: api)

        let request = AISelfRequest(
            phone: "+12025550123",
            selfieKey: "s3://bucket/selfie.jpg",
            voiceKey: "s3://bucket/voice.m4a"
        )
        let card = try await client.createAISelf(request)
        #expect(card.name == "SEMI")
        #expect(api.recordedCalls() == ["POST /v1/ai-selves"])
    }

    @Test func liveOnboardingClient_surfaces_server_error() async {
        let api = MockAPIClient(artificialDelay: .zero)
        api.stub(.post, "/v1/ai-selves", thenThrowing: .status(500, Data()))
        let client = LiveOnboardingClient(api: api)

        let request = AISelfRequest(phone: "x", selfieKey: "y", voiceKey: "z")
        await #expect(throws: APIError.self) {
            _ = try await client.createAISelf(request)
        }
    }
}
