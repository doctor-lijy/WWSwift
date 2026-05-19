import Foundation

enum ContractPreviewCalculator {
    /// 简化可开/成本估算（对照 weexios `CalcHelper` 的占位实现，非精确保证金公式）。
    static func preview(
        availableBalanceUSDT: Double,
        leverage: Int,
        price: Double,
        size: Double
    ) -> (maxOpen: String, cost: String) {
        guard price > 0, leverage > 0 else {
            return ("--", "-- USDT")
        }
        let maxQty = availableBalanceUSDT * Double(leverage) / price
        let maxText = String(format: "%.4f", maxQty)
        let cost = size > 0 ? (size * price / Double(leverage)) : 0
        let costText = String(format: "%.2f USDT", cost)
        return (maxText, costText)
    }

    static func parseBalanceNumber(from display: String) -> Double? {
        let filtered = display
            .replacingOccurrences(of: "USDT", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(filtered)
    }
}
