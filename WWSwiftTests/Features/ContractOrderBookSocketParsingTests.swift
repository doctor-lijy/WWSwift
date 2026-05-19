import XCTest
@testable import WWSwift

final class ContractOrderBookSocketParsingTests: XCTestCase {
    func testOrderBookSnapshot_mock_hasFiveLevels() {
        let book = ContractOrderBookSnapshot.mock()
        XCTAssertEqual(book.bids.count, 5)
        XCTAssertEqual(book.asks.count, 5)
    }
}
