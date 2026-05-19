import XCTest
@testable import WWSwift

final class PlaceOrderRequestTests: XCTestCase {
    private func makeRequest(
        orderType: PlaceOrderType = .limit,
        size: String = "0.01",
        price: String? = "65000",
        leverage: Int = 20
    ) -> PlaceOrderRequest {
        PlaceOrderRequest(
            contractId: "10000001",
            orderSide: .buy,
            orderType: orderType,
            size: size,
            price: price,
            marginMode: .shared,
            leverage: leverage
        )
    }

    func test_validate_limitOrder_success() {
        let result = makeRequest().validate()
        guard case .success = result else {
            return XCTFail("Expected success")
        }
    }

    func test_validate_marketOrder_allowsEmptyPrice() {
        let result = makeRequest(orderType: .market, price: nil).validate()
        guard case .success = result else {
            return XCTFail("Expected success")
        }
    }

    func test_validate_limitOrder_requiresPrice() {
        let result = makeRequest(price: nil).validate()
        XCTAssertEqual(result.failure, .missingLimitPrice)
    }

    func test_validate_rejectsInvalidSize() {
        let result = makeRequest(size: "0").validate()
        XCTAssertEqual(result.failure, .invalidSize)
    }

    func test_validate_rejectsInvalidLeverage() {
        let result = makeRequest(leverage: 200).validate()
        XCTAssertEqual(result.failure, .invalidLeverage)
    }

    func test_apiParameters_includesMarginModeAndType() {
        let params = makeRequest().apiParameters()
        XCTAssertEqual(params["marginMode"] as? String, "SHARED")
        XCTAssertEqual(params["type"] as? String, "LIMIT")
        XCTAssertEqual(params["orderSide"] as? String, "BUY")
    }
}

private extension Result {
    var failure: Failure? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
}
