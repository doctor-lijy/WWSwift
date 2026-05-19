import Foundation
import PHNet

/// 合约私有推送（`TYPE_SOCKET_CONTRACT_TRADEDATA` / 306）：持仓、抵押品等。
///
/// weexios 对照：`ContractTradeManager phraseTradeSocketData`
final class ContractPrivateTradeSocketService {
    static let shared = ContractPrivateTradeSocketService()

    private let workQueue = DispatchQueue(label: "wwswift.contract.private.socket", qos: .userInitiated)
    private var positionsById: [String: ContractPosition] = [:]
    private var availableBalanceUSDT: String?
    private let lock = NSLock()

    var onPositionsUpdate: (() -> Void)?
    var onAccountUpdate: (() -> Void)?
    var onPrivateConnectionChanged: ((Bool) -> Void)?

    private var didRegister = false

    private init() {}

    func registerReceivers() {
        guard !didRegister else { return }
        didRegister = true

        let types: [NSNumber] = [
            NSNumber(value: TYPE_SOCKET_CONNECTED_CONTRACT_PRIVATE),
            NSNumber(value: TYPE_SOCKET_DISCONNECT_CONTRACT_PRIVATE),
            NSNumber(value: TYPE_SOCKET_CONTRACT_TRADEDATA),
        ]
        SocketManager.getInstance().registReceiver(types, queue: workQueue) { [weak self] result in
            self?.handle(result)
        }
    }

    func positions(contractId: String?, onlyCurrent: Bool) -> [ContractPosition] {
        lock.lock()
        defer { lock.unlock() }
        let all = Array(positionsById.values)
        guard onlyCurrent, let contractId else { return all }
        return all.filter { $0.contractId == contractId }
    }

    func availableBalanceText() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return availableBalanceUSDT
    }

    private func handle(_ data: SocketData) {
        switch data.type {
        case TYPE_SOCKET_CONNECTED_CONTRACT_PRIVATE:
            DispatchQueue.main.async { [weak self] in
                self?.onPrivateConnectionChanged?(true)
            }
        case TYPE_SOCKET_DISCONNECT_CONTRACT_PRIVATE:
            lock.lock()
            positionsById.removeAll()
            availableBalanceUSDT = nil
            lock.unlock()
            DispatchQueue.main.async { [weak self] in
                self?.onPrivateConnectionChanged?(false)
                self?.onPositionsUpdate?()
                self?.onAccountUpdate?()
            }
        case TYPE_SOCKET_CONTRACT_TRADEDATA:
            parseTradeData(rawJSON: data.data)
        default:
            break
        }
    }

    private func parseTradeData(rawJSON: String?) {
        let raw = rawJSON ?? ""
        guard !raw.isEmpty,
              let payload = raw.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: payload) as? [String: Any],
              let msg = root["msg"] as? [String: Any]
        else { return }

        let event = msg["event"] as? String
        let isSnapshot = event == "Snapshot"
        guard let dataDic = msg["data"] as? [String: Any] else { return }

        if isSnapshot {
            lock.lock()
            positionsById.removeAll()
            lock.unlock()
        }

        if let positionArr = dataDic["position"] as? [[String: Any]] {
            applyPositions(positionArr, isSnapshot: isSnapshot)
        }
        if let collateralArr = dataDic["collateral"] as? [[String: Any]] {
            applyCollateral(collateralArr)
        }
    }

    private func applyPositions(_ items: [[String: Any]], isSnapshot: Bool) {
        lock.lock()
        if isSnapshot {
            positionsById.removeAll()
        }
        for dict in items {
            guard let positionId = dict["positionId"] as? String,
                  let contractId = dict["contractId"] as? String
            else { continue }
            let size = stringValue(dict["size"])
            if Double(size) == 0 {
                positionsById.removeValue(forKey: positionId)
                continue
            }
            let side = stringValue(dict["side"])
            let pnl = stringValue(dict["unrealizedProfitStr"])
                .isEmpty ? stringValue(dict["unrealizedPnL"]) : stringValue(dict["unrealizedProfitStr"])
            positionsById[positionId] = ContractPosition(
                positionId: positionId,
                contractId: contractId,
                side: side,
                size: size,
                unrealizedPnL: pnl.isEmpty ? "—" : pnl
            )
        }
        lock.unlock()
        DispatchQueue.main.async { [weak self] in
            self?.onPositionsUpdate?()
        }
    }

    private func applyCollateral(_ items: [[String: Any]]) {
        // 优先取全仓 USDT 抵押的 marginGroupAvailableAmount，否则 amount
        var picked: String?
        for dict in items {
            let coinId = stringValue(dict["coinId"])
            guard coinId.contains("USDT") || coinId == "2" else { continue }
            let marginMode = stringValue(dict["marginMode"])
            let available = stringValue(dict["marginGroupAvailableAmount"])
            let amount = stringValue(dict["amount"])
            let value = !available.isEmpty ? available : amount
            if marginMode == "SHARED" || marginMode.isEmpty {
                picked = value
                break
            }
            if picked == nil {
                picked = value
            }
        }
        guard let picked, !picked.isEmpty else { return }
        lock.lock()
        availableBalanceUSDT = "\(picked) USDT"
        lock.unlock()
        DispatchQueue.main.async { [weak self] in
            self?.onAccountUpdate?()
        }
    }

    private func stringValue(_ value: Any?) -> String {
        switch value {
        case let s as String: return s
        case let n as NSNumber: return n.stringValue
        default: return ""
        }
    }
}
