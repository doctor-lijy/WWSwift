import Foundation

enum ContractListSegment: Int, CaseIterable {
    case positions
    case activeOrders

    var title: String {
        switch self {
        case .positions: return "持仓"
        case .activeOrders: return "当前委托"
        }
    }
}

@MainActor
final class ContractViewModel {
    private(set) var symbols: [ContractSymbol] = []
    private(set) var selectedSymbol: ContractSymbol?
    private(set) var segment: ContractListSegment = .positions
    private(set) var positions: [ContractPosition] = []
    private(set) var activeOrders: [ContractOrder] = []
    private(set) var tableRows: [String] = []
    private(set) var errorMessage: String?
    private(set) var currentTick: ContractMarketTick?
    private(set) var socketConnected: Bool = false

    var onUpdate: (() -> Void)?
    var onTickUpdate: (() -> Void)?

    private let configService: ContractConfigService
    private let tradingService: ContractTradingService
    private let orderService: ContractOrderService
    private let positionService: ContractPositionService
    private let environmentManager: EnvironmentManager
    private let marketSocket: ContractMarketSocketService

    init(
        configService: ContractConfigService,
        tradingService: ContractTradingService,
        orderService: ContractOrderService,
        positionService: ContractPositionService,
        environmentManager: EnvironmentManager,
        marketSocket: ContractMarketSocketService = .shared
    ) {
        self.configService = configService
        self.tradingService = tradingService
        self.orderService = orderService
        self.positionService = positionService
        self.environmentManager = environmentManager
        self.marketSocket = marketSocket

        bindSocket()
    }

    private func bindSocket() {
        socketConnected = false
        marketSocket.onConnectionStateChanged = { [weak self] connected in
            self?.socketConnected = connected
            self?.onTickUpdate?()
        }
        marketSocket.onTickerUpdate = { [weak self] _ in
            guard let self = self, let symbol = self.selectedSymbol else { return }
            if let tick = self.marketSocket.ticker(forContractId: symbol.contractId) {
                self.currentTick = tick
                self.onTickUpdate?()
            }
        }
    }

    func submitOrder(_ request: PlaceOrderRequest) async -> Result<String, APIError> {
        let result = await orderService.placeOrder(request)
        if case .success = result {
            segment = .activeOrders
            await reloadList()
        }
        return result
    }

    func loadInitialData() async {
        errorMessage = nil
        let result = await configService.fetchSymbols()
        switch result {
        case .success(let list):
            symbols = list
            selectedSymbol = list.first
            refreshCurrentTickFromCache()
            await reloadList()
        case .failure(let error):
            errorMessage = error.message
            tableRows = []
            notify()
        }
    }

    func selectSymbol(_ symbol: ContractSymbol) async {
        selectedSymbol = symbol
        refreshCurrentTickFromCache()
        await reloadList()
    }

    /// 选中币对变化或冷启动时，从 socket 缓存直接拉一次最新行情。
    private func refreshCurrentTickFromCache() {
        guard let symbol = selectedSymbol else {
            currentTick = nil
            return
        }
        currentTick = marketSocket.ticker(forContractId: symbol.contractId)
        onTickUpdate?()
    }

    func setSegment(_ segment: ContractListSegment) async {
        self.segment = segment
        await reloadList()
    }

    func position(at index: Int) -> ContractPosition? {
        guard positions.indices.contains(index) else { return nil }
        return positions[index]
    }

    func order(at index: Int) -> ContractOrder? {
        guard activeOrders.indices.contains(index) else { return nil }
        return activeOrders[index]
    }

    func cancelOrder(orderId: String) async -> Result<Void, APIError> {
        let result = await positionService.cancelOrder(orderId: orderId)
        if case .success = result {
            await reloadList()
        }
        return result
    }

    func updateOrderLimitPrice(orderId: String, price: String) async -> Result<Void, APIError> {
        let result = await positionService.updateLimitPrice(orderId: orderId, price: price)
        if case .success = result {
            await reloadList()
        }
        return result
    }

    func updateOrderTriggerPrice(orderId: String, triggerPrice: String) async -> Result<Void, APIError> {
        let result = await positionService.updateTriggerPrice(orderId: orderId, triggerPrice: triggerPrice)
        if case .success = result {
            await reloadList()
        }
        return result
    }

    func closeAllPositions(for position: ContractPosition) async -> Result<Void, APIError> {
        let result = await positionService.closeAllPositions(contractId: position.contractId)
        if case .success = result {
            await reloadList()
        }
        return result
    }

    private func reloadList() async {
        errorMessage = nil
        guard let symbol = selectedSymbol else {
            positions = []
            activeOrders = []
            tableRows = []
            notify()
            return
        }

        switch segment {
        case .positions:
            positions = mockPositions(for: symbol)
            tableRows = positions.map(\.displayTitle)
            notify()
        case .activeOrders:
            let result = await tradingService.fetchActiveOrders(contractId: symbol.contractId)
            switch result {
            case .success(let orders):
                activeOrders = orders
                tableRows = orders.isEmpty ? ["暂无当前委托"] : orders.map(\.displayTitle)
            case .failure(let error):
                activeOrders = []
                errorMessage = error.message
                tableRows = environmentManager.current == .mock ? [] : ["加载失败: \(error.message)"]
            }
            notify()
        }
    }

    private func mockPositions(for symbol: ContractSymbol) -> [ContractPosition] {
        [
            ContractPosition(
                positionId: "pos-1",
                contractId: symbol.contractId,
                side: "LONG",
                size: "0.05",
                unrealizedPnL: "+12.50"
            ),
            ContractPosition(
                positionId: "pos-2",
                contractId: symbol.contractId,
                side: "SHORT",
                size: "0.02",
                unrealizedPnL: "-3.20"
            )
        ]
    }

    private func notify() {
        onUpdate?()
    }
}
