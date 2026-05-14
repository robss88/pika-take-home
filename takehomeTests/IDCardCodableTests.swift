import Foundation
import Testing
@testable import takehome

@Suite("IDCard JSON round-trip")
struct IDCardCodableTests {
    @Test func canned_round_trips_through_shared_encoder_and_decoder() throws {
        let original = IDCard.canned
        let data = try JSONEncoder.default.encode(original)
        let decoded = try JSONDecoder.default.decode(IDCard.self, from: data)
        #expect(decoded == original)
    }

    @Test func encoder_uses_snake_case_keys() throws {
        let data = try JSONEncoder.default.encode(IDCard.canned)
        let json = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(json["born_on"] != nil)
        #expect(json["find_me_on"] != nil)
        #expect(json["barcode_payload"] != nil)
        #expect(json["bornOn"] == nil)
    }

    @Test func authToken_round_trips() throws {
        let token = AuthToken(value: "abc-123")
        let data = try JSONEncoder.default.encode(token)
        let decoded = try JSONDecoder.default.decode(AuthToken.self, from: data)
        #expect(decoded == token)
    }
}
