import Foundation

/// 合约 24h 行情快照（socket `TYPE_SOCKET_CONTRACT_MARKET` / `_SINGLE`）。
///
/// JSON 形态（来自 weexios `ContractMarketModel`）：
/// ```
/// {
///   "channel": "contract.market.<contractId?>",
///   "data": [
///     { "contractId": "10000001", "lastPrice": "...", "priceChangePercent": "...",
///       "value": "...", "high": "...", "low": "...", "markPrice": "..." }
///   ]
/// }
/// ```
struct ContractMarketTick: Decodable, Equatable {
    let contractId: String
    let lastPrice: String?
    let markPrice: String?
    let priceChangePercent: String?
    let high: String?
    let low: String?
    let value: String?
}

struct ContractMarketEnvelope: Decodable {
    let channel: String?
    let data: [ContractMarketTick]?
}
