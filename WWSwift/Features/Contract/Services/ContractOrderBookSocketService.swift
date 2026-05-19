import Foundation
import PHNet

/// 合约盘口 Socket（`TYPE_SOCKET_CONTRACT_ORDERBOOK` / 305）。
final class ContractOrderBookSocketService {
    static let shared = ContractOrderBookSocketService()

    private let workQueue = DispatchQueue(label: "wwswift.contract.orderbook.socket", qos: .userInitiated)
    private var subscribedContractId: String?
    private var snapshot = ContractOrderBookSnapshot.mock()
    private let lock = NSLock()

    var onSnapshotUpdate: ((ContractOrderBookSnapshot) -> Void)?

    private var didRegister = false

    private init() {}

    func registerReceivers() {
        guard !didRegister else { return }
        didRegister = true

        let types: [NSNumber] = [
            NSNumber(value: TYPE_SOCKET_CONTRACT_ORDERBOOK),
        ]
        SocketManager.getInstance().registReceiver(types, queue: workQueue) { [weak self] result in
            self?.handle(result)
        }
    }

    func subscribe(contractId: String) {
        guard !contractId.isEmpty else { return }
        if subscribedContractId == contractId { return }
        if let previous = subscribedContractId {
            SocketManager.getInstance().unSubScribeOrderBook(ofContract: previous)
        }
        subscribedContractId = contractId
        lock.lock()
        snapshot = ContractOrderBookSnapshot.mock()
        lock.unlock()
        SocketManager.getInstance().subScribeOrderBook(ofContract: contractId)
    }

    func unsubscribeAll() {
        if let id = subscribedContractId {
            SocketManager.getInstance().unSubScribeOrderBook(ofContract: id)
        }
        subscribedContractId = nil
    }

    func currentSnapshot() -> ContractOrderBookSnapshot {
        lock.lock()
        defer { lock.unlock() }
        return snapshot
    }

    private func handle(_ data: SocketData) {
        guard data.type == TYPE_SOCKET_CONTRACT_ORDERBOOK else { return }
        let raw = data.data ?? ""
        guard !raw.isEmpty,
              let payload = raw.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: payload) as? [String: Any]
        else { return }

        let channel = json["channel"] as? String
        if let channel, let subscribed = subscribedContractId {
            let parts = channel.split(separator: ".")
            if let id = parts.last, String(id) != subscribed { return }
        }

        guard let dataArray = json["data"] as? [[String: Any]], let last = dataArray.last else { return }

        let asks = parseLevels(last["asks"]).sorted {
            (Double($0.price) ?? 0) < (Double($1.price) ?? 0)
        }
        let bids = parseLevels(last["bids"]).sorted {
            (Double($0.price) ?? 0) > (Double($1.price) ?? 0)
        }
        let lastPrice = (bids.first?.price ?? asks.first?.price) ?? snapshot.lastPrice

        let book = ContractOrderBookSnapshot(
            bids: Array(bids.prefix(5)),
            asks: Array(asks.prefix(5)),
            lastPrice: lastPrice,
            pricePrecision: 1
        )

        lock.lock()
        snapshot = book
        lock.unlock()

        DispatchQueue.main.async { [weak self] in
            self?.onSnapshotUpdate?(book)
        }
    }

    private func parseLevels(_ raw: Any?) -> [ContractOrderBookLevel] {
        guard let array = raw as? [Any] else { return [] }
        var levels: [ContractOrderBookLevel] = []
        for item in array {
            if let pair = item as? [Any], pair.count >= 2 {
                let size = stringValue(pair[0])
                let price = stringValue(pair[1])
                if size != "0" {
                    levels.append(ContractOrderBookLevel(price: price, size: size))
                }
            } else if let dict = item as? [String: Any] {
                let size = stringValue(dict["size"])
                let price = stringValue(dict["price"])
                if size != "0" {
                    levels.append(ContractOrderBookLevel(price: price, size: size))
                }
            }
        }
        return levels
    }

    private func stringValue(_ value: Any?) -> String {
        switch value {
        case let s as String: return s
        case let n as NSNumber: return n.stringValue
        default: return ""
        }
    }
}
