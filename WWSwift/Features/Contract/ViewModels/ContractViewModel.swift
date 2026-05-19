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
    private(set) var tableRows: [String] = []
    private(set) var errorMessage: String?

    var onUpdate: (() -> Void)?

    private let configService: ContractConfigService
    private let tradingService: ContractTradingService
    private let orderService: ContractOrderService
    private let environmentManager: EnvironmentManager

    init(
        configService: ContractConfigService,
        tradingService: ContractTradingService,
        orderService: ContractOrderService,
        environmentManager: EnvironmentManager
    ) {
        self.configService = configService
        self.tradingService = tradingService
        self.orderService = orderService
        self.environmentManager = environmentManager
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
            await reloadList()
        case .failure(let error):
            errorMessage = error.message
            tableRows = []
            notify()
        }
    }

    func selectSymbol(_ symbol: ContractSymbol) async {
        selectedSymbol = symbol
        await reloadList()
    }

    func setSegment(_ segment: ContractListSegment) async {
        self.segment = segment
        await reloadList()
    }

    private func reloadList() async {
        errorMessage = nil
        guard let symbol = selectedSymbol else {
            tableRows = []
            notify()
            return
        }

        switch segment {
        case .positions:
            tableRows = mockPositions(for: symbol).map(\.displayTitle)
            notify()
        case .activeOrders:
            if environmentManager.current == .mock {
                let result = await tradingService.fetchActiveOrders(contractId: symbol.contractId)
                switch result {
                case .success(let orders):
                    tableRows = orders.map(\.displayTitle)
                case .failure(let error):
                    errorMessage = error.message
                    tableRows = []
                }
            } else {
                let result = await tradingService.fetchActiveOrders(contractId: symbol.contractId)
                switch result {
                case .success(let orders):
                    tableRows = orders.isEmpty ? ["暂无当前委托"] : orders.map(\.displayTitle)
                case .failure(let error):
                    errorMessage = error.message
                    tableRows = ["加载失败: \(error.message)"]
                }
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
