import XCTest
@testable import SFSymbolsProvider

final class SFSymbolsProviderTests: XCTestCase {
    func testInitialization() {
        let provider = SFSymbolsProvider()
        XCTAssertNotNil(provider)
    }
}
