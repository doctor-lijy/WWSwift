import XCTest
@testable import WWSwift

final class ContractPreviewCalculatorTests: XCTestCase {
    func testPreview_computesMaxOpenAndCost() {
        let result = ContractPreviewCalculator.preview(
            availableBalanceUSDT: 1000,
            leverage: 20,
            price: 50_000,
            size: 0.1
        )
        XCTAssertEqual(result.maxOpen, "0.4000")
        XCTAssertEqual(result.cost, "250.00 USDT")
    }

    func testParseBalanceNumber_stripsUSDT() {
        let value = ContractPreviewCalculator.parseBalanceNumber(from: "1,234.56 USDT")
        XCTAssertEqual(value, 1234.56)
    }
}
