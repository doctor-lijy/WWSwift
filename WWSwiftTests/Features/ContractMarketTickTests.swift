import XCTest
@testable import WWSwift

final class ContractMarketTickTests: XCTestCase {
    func test_decode_marketEnvelope_singlePayload() throws {
        let json = #"""
        {
          "channel": "contract.market.10000001",
          "data": [
            {
              "contractId": "10000001",
              "lastPrice": "67500.12",
              "markPrice": "67510.00",
              "priceChangePercent": "0.0123",
              "high": "68000",
              "low": "66000",
              "value": "12345678"
            }
          ]
        }
        """#
        let envelope = try JSONDecoder().decode(
            ContractMarketEnvelope.self,
            from: Data(json.utf8)
        )
        XCTAssertEqual(envelope.channel, "contract.market.10000001")
        XCTAssertEqual(envelope.data?.count, 1)
        let tick = try XCTUnwrap(envelope.data?.first)
        XCTAssertEqual(tick.contractId, "10000001")
        XCTAssertEqual(tick.lastPrice, "67500.12")
        XCTAssertEqual(tick.priceChangePercent, "0.0123")
    }

    func test_decode_marketEnvelope_batchPayload() throws {
        let json = #"""
        {
          "channel": "contract.market",
          "data": [
            { "contractId": "10000001", "lastPrice": "67500", "priceChangePercent": "0.01" },
            { "contractId": "10000002", "lastPrice": "3200",  "priceChangePercent": "-0.02" }
          ]
        }
        """#
        let envelope = try JSONDecoder().decode(
            ContractMarketEnvelope.self,
            from: Data(json.utf8)
        )
        XCTAssertEqual(envelope.data?.count, 2)
        XCTAssertEqual(envelope.data?[1].contractId, "10000002")
        XCTAssertEqual(envelope.data?[1].priceChangePercent, "-0.02")
    }

    func test_decode_marketEnvelope_missingOptionalFields() throws {
        let json = #"""
        { "data": [ { "contractId": "10000001" } ] }
        """#
        let envelope = try JSONDecoder().decode(
            ContractMarketEnvelope.self,
            from: Data(json.utf8)
        )
        XCTAssertNil(envelope.channel)
        XCTAssertEqual(envelope.data?.first?.lastPrice, nil)
    }
}
