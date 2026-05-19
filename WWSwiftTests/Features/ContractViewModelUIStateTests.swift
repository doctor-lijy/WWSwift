import XCTest
@testable import WWSwift

@MainActor
final class ContractViewModelUIStateTests: XCTestCase {
    func testSetOpenCloseMode_updatesSettings() {
        let vm = makeViewModel()
        vm.setOpenCloseMode(.close)
        XCTAssertEqual(vm.tradeSettings.openCloseMode, .close)
    }

    func testUpdateSizePercent_updatesSizeInput() {
        let vm = makeViewModel()
        vm.updateSizePercent(50)
        // 默认可用 1234.56 USDT、20x、Mock 盘口价 97234.5 → 50% 仓位约 0.1270
        XCTAssertEqual(vm.sizeInputText, "0.1270")
    }

    private func makeViewModel() -> ContractViewModel {
        let suite = "WWSwiftTests.ContractVM.UI"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let storage = UserDefaultsStorage(defaults: defaults)
        let environment = EnvironmentManager(storage: storage)
        environment.setCurrent(.mock, syncToPHNet: false)
        let session = SessionStore(storage: storage)
        let api = APIClient(environment: environment, session: session)
        return ContractViewModel(
            configService: ContractConfigService(apiClient: api),
            tradingService: ContractTradingService(apiClient: api),
            orderService: ContractOrderService(apiClient: api),
            positionService: ContractPositionService(apiClient: api),
            environmentManager: environment,
            marketSocket: ContractMarketSocketService.shared
        )
    }
}
