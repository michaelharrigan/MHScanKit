#if !os(macOS)
import XCTest
@testable import MHScanKit

final class MHScanKitTests: XCTestCase {
    func testSimpleErrorCases() {
        
        // Test 1
        let errorCode = MHScanKitError.unexpected(code: 123)
        XCTAssertTrue(errorCode.description == "Error 123")
        
        // Test 2
        let errorCodeTwo = MHScanKitError.genericError(message: "Testing the error out!")
        XCTAssertTrue(errorCodeTwo.description == "Error. We don't have much more info for this. - Testing the error out!")
    }
}
#endif
