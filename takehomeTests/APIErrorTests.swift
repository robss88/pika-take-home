import Foundation
import Testing
@testable import takehome

@Suite("APIError")
struct APIErrorTests {
    @Test func status_error_describes_status_code() {
        let err = APIError.status(503, Data())
        #expect(err.errorDescription?.contains("503") == true)
    }

    @Test func mockUnconfigured_describes_the_offending_path() {
        let err = APIError.mockUnconfigured("POST /v1/whatever")
        #expect(err.errorDescription?.contains("/v1/whatever") == true)
    }

    @Test func cancelled_has_friendly_description() {
        let err = APIError.cancelled
        #expect(err.errorDescription?.isEmpty == false)
    }

    @Test func decode_error_includes_inner_detail() {
        let err = APIError.decode("missing key 'name'")
        #expect(err.errorDescription?.contains("missing key") == true)
    }
}
