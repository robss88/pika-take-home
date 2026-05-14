import Foundation
import Testing
@testable import takehome

@Suite("Endpoint convenience builders")
struct EndpointBuilderTests {
    @Test func no_body_endpoint_has_nil_body_and_correct_method() {
        let endpoint: Endpoint<IDCard> = .json(.get, "/v1/ai-selves/123")
        #expect(endpoint.method == .get)
        #expect(endpoint.path == "/v1/ai-selves/123")
        #expect(endpoint.body == nil)
    }

    @Test func bodied_endpoint_encodes_request_as_snake_case_json() throws {
        let request = AISelfRequest(
            phone: "+12025550123",
            selfieKey: "selfie.jpg",
            voiceKey: "voice.m4a"
        )
        let endpoint: Endpoint<IDCard> = .json(.post, "/v1/ai-selves", body: request)
        let bodyData = try #require(endpoint.body)
        let json = try #require(
            try JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
        )
        #expect(json["phone"] as? String == "+12025550123")
        // The shared encoder uses .convertToSnakeCase — selfieKey → selfie_key.
        #expect(json["selfie_key"] as? String == "selfie.jpg")
        #expect(json["voice_key"] as? String == "voice.m4a")
    }

    @Test func decode_handles_snake_case_response() throws {
        let endpoint: Endpoint<IDCard> = .json(.get, "/v1/ai-selves/123")
        let json = """
        {
          "name": "SEMI",
          "born_on": "FEB 11, 2026",
          "location": "SF",
          "status": "ALIVE",
          "find_me_on": "pika.me/x",
          "avatar_url": null,
          "barcode_payload": "X-1"
        }
        """.data(using: .utf8)!
        let card = try endpoint.decode(json)
        #expect(card.name == "SEMI")
        #expect(card.bornOn == "FEB 11, 2026")
        #expect(card.findMeOn == "pika.me/x")
        #expect(card.avatarURL == nil)
    }

    @Test func decode_throws_APIError_decode_on_malformed_json() {
        let endpoint: Endpoint<IDCard> = .json(.get, "/v1/ai-selves/123")
        #expect(throws: APIError.self) {
            _ = try endpoint.decode(Data("not json".utf8))
        }
    }
}
