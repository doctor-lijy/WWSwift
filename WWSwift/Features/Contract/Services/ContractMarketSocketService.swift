import Foundation
import PHNet

/// 合约 **公有** Socket 服务（不依赖登录）。
///
/// 当前覆盖：
/// - `TYPE_SOCKET_CONNECTED_CONTRACT_PUBLIC` (502)：连接建立 → 触发全市场订阅
/// - `TYPE_SOCKET_DISCONNECT_CONTRACT_PUBLIC` (504)：断开
/// - `TYPE_SOCKET_CONTRACT_MARKET` (301)：批量 24h 行情
/// - `TYPE_SOCKET_CONTRACT_MARKET_SINGLE` (310)：单币种 24h 行情
///
/// 设计：单例 + 主线程回调。回调通过 `onTickerUpdate(_:)` 注册闭包。
/// 暂不做引用计数订阅；后续扩 OrderBook / LastTrade / Kline 时再细化。
final class ContractMarketSocketService {
    static let shared = ContractMarketSocketService()

    private let workQueue = DispatchQueue(label: "wwswift.contract.market.socket", qos: .userInitiated)

    /// 最近一次行情快照，按 contractId 索引
    private var latestSnapshot: [String: ContractMarketTick] = [:]
    private let snapshotLock = NSLock()

    /// 回调（主线程）。多个监听者用同一回调时各自管理 weak self。
    var onTickerUpdate: (([ContractMarketTick]) -> Void)?
    var onConnectionStateChanged: ((Bool) -> Void)?

    private var didRegister = false

    private init() {}

    // MARK: - Register

    func registerReceivers() {
        guard !didRegister else { return }
        didRegister = true

        let types: [NSNumber] = [
            NSNumber(value: TYPE_SOCKET_CONNECTED_CONTRACT_PUBLIC),
            NSNumber(value: TYPE_SOCKET_DISCONNECT_CONTRACT_PUBLIC),
            NSNumber(value: TYPE_SOCKET_CONTRACT_MARKET),
            NSNumber(value: TYPE_SOCKET_CONTRACT_MARKET_SINGLE),
        ]

        SocketManager.getInstance().registReceiver(
            types,
            queue: workQueue
        ) { [weak self] result in
            self?.handle(result)
        }
    }

    // MARK: - Subscribe API

    /// 批量订阅某些合约的 24h 行情。在收到 502 连接后调用才会真正生效。
    func subscribeMarkets(_ symbolIds: Set<String>) {
        guard !symbolIds.isEmpty else { return }
        SocketManager.getInstance().subscribeMarkets(ofContract_Batch: symbolIds)
    }

    func unsubscribeMarkets(_ symbolIds: Set<String>) {
        guard !symbolIds.isEmpty else { return }
        SocketManager.getInstance().unSubscribeMarkets(ofContract_Batch: symbolIds)
    }

    func subscribeAllMarkets() {
        SocketManager.getInstance().subscribeMarketsOfContract()
    }

    // MARK: - Snapshot accessor

    func ticker(forContractId contractId: String) -> ContractMarketTick? {
        snapshotLock.lock()
        defer { snapshotLock.unlock() }
        return latestSnapshot[contractId]
    }

    // MARK: - Dispatch

    private func handle(_ data: SocketData) {
        switch data.type {
        case TYPE_SOCKET_CONNECTED_CONTRACT_PUBLIC:
            NSLog("[Socket] contract public connected")
            DispatchQueue.main.async { [weak self] in self?.onConnectionStateChanged?(true) }
            // 与 weexios 行为对齐：连接成功后自动订阅全市场
            subscribeAllMarkets()

        case TYPE_SOCKET_DISCONNECT_CONTRACT_PUBLIC:
            NSLog("[Socket] contract public disconnected")
            DispatchQueue.main.async { [weak self] in self?.onConnectionStateChanged?(false) }

        case TYPE_SOCKET_CONTRACT_MARKET, TYPE_SOCKET_CONTRACT_MARKET_SINGLE:
            parseTickers(rawJSON: data.data)

        default:
            break
        }
    }

    private func parseTickers(rawJSON: String?) {
        guard let raw = rawJSON, let payload = raw.data(using: .utf8) else { return }
        do {
            let envelope = try JSONDecoder().decode(ContractMarketEnvelope.self, from: payload)
            guard let ticks = envelope.data, !ticks.isEmpty else { return }
            snapshotLock.lock()
            for t in ticks { latestSnapshot[t.contractId] = t }
            snapshotLock.unlock()
            DispatchQueue.main.async { [weak self] in
                self?.onTickerUpdate?(ticks)
            }
        } catch {
            NSLog("[Socket] parse market tick failed: \(error)")
        }
    }
}
