import XCTest
@testable import MHScanKit

final class MHScanKitTests: XCTestCase {
    func testSimpleErrorCases() {
        
        // Test 1
        let errorCode = MHSKError.unexpected(code: 123)
        XCTAssertTrue(errorCode.description == "Error 123")
        
        // Test 2
        let errorCodeTwo = MHSKError.genericError(message: "Testing the error out!")
        XCTAssertTrue(errorCodeTwo.description == "Testing the error out!")
    }
}
