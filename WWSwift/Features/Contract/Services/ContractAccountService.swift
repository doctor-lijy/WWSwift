import Foundation

/// 合约账户可用余额（来自私有 Socket 抵押品推送，M3 简化版）。
final class ContractAccountService {
    private let privateTradeSocket: ContractPrivateTradeSocketService

    init(privateTradeSocket: ContractPrivateTradeSocketService = .shared) {
        self.privateTradeSocket = privateTradeSocket
    }

    func availableBalanceDisplay() -> String? {
        privateTradeSocket.availableBalanceText()
    }
}
