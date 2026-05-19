import Foundation

struct ContractOrderBookLevel: Equatable {
    let price: String
    let size: String
}

struct ContractOrderBookSnapshot: Equatable {
    let bids: [ContractOrderBookLevel]
    let asks: [ContractOrderBookLevel]
    let lastPrice: String
    let pricePrecision: Int

    static func mock(lastPrice: String = "97234.5") -> ContractOrderBookSnapshot {
        let base = Double(lastPrice) ?? 97_234.5
        let asks = (1...5).map { i in
            ContractOrderBookLevel(
                price: String(format: "%.1f", base + Double(i) * 0.5),
                size: String(format: "%.3f", 1.2 + Double(i) * 0.1)
            )
        }
        let bids = (1...5).map { i in
            ContractOrderBookLevel(
                price: String(format: "%.1f", base - Double(i) * 0.5),
                size: String(format: "%.3f", 0.9 + Double(i) * 0.08)
            )
        }
        return ContractOrderBookSnapshot(
            bids: bids,
            asks: asks,
            lastPrice: lastPrice,
            pricePrecision: 1
        )
    }
}
