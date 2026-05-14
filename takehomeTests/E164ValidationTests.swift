import Foundation
import Testing
@testable import takehome

@Suite("E164 + USPhoneNumberFormatter")
struct E164ValidationTests {
    private let formatter = USPhoneNumberFormatter()

    @Test func valid_ten_digit_us_number_parses() {
        let parsed = formatter.parse("2025550123")
        #expect(parsed == E164(countryCode: "1", national: "2025550123"))
        #expect(parsed?.e164String == "+12025550123")
    }

    @Test func parses_formatted_input_with_punctuation() {
        let parsed = formatter.parse("(202) 555-0123")
        #expect(parsed?.national == "2025550123")
    }

    @Test func rejects_short_inputs() {
        #expect(formatter.parse("202555012") == nil)
    }

    @Test func rejects_too_long_inputs() {
        #expect(formatter.parse("20255501234") == nil)
    }

    @Test func rejects_leading_zero_or_one_us_numbers() {
        #expect(formatter.parse("1234567890") == nil)
        #expect(formatter.parse("0234567890") == nil)
    }

    @Test func partial_formatting_grows_with_input() {
        #expect(formatter.formatPartial("") == "")
        #expect(formatter.formatPartial("2") == "(2")
        #expect(formatter.formatPartial("202") == "(202")
        #expect(formatter.formatPartial("2025") == "(202) 5")
        #expect(formatter.formatPartial("202555") == "(202) 555")
        #expect(formatter.formatPartial("2025550123") == "(202) 555-0123")
    }
}
