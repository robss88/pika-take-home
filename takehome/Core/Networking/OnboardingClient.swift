import Foundation

protocol OnboardingClient: Sendable {
    nonisolated func createAISelf(_ request: AISelfRequest) async throws -> IDCard
}

// MARK: - Live

nonisolated struct LiveOnboardingClient: OnboardingClient {
    let api: any APIClient

    func createAISelf(_ request: AISelfRequest) async throws -> IDCard {
        let endpoint: Endpoint<IDCard> = .json(.post, "/v1/ai-selves", body: request)
        return try await api.send(endpoint)
    }
}

// MARK: - Mock

nonisolated struct MockOnboardingClient: OnboardingClient {
    var canned: IDCard = .canned
    var delay: Duration = .milliseconds(1200)
    var shouldFail: Bool = false

    func createAISelf(_ request: AISelfRequest) async throws -> IDCard {
        try await Task.sleep(for: delay)
        if shouldFail {
            throw APIError.status(500, Data())
        }
        // Echo the selfie URL back as the avatar so the success screen shows the
        // photo the user just took.
        return IDCard(
            name: canned.name,
            bornOn: canned.bornOn,
            location: canned.location,
            status: canned.status,
            findMeOn: canned.findMeOn,
            avatarURL: URL(string: request.selfieKey),
            barcodePayload: canned.barcodePayload
        )
    }
}
