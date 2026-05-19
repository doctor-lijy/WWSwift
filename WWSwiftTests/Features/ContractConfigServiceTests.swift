import XCTest
@testable import WWSwift

final class ContractConfigServiceTests: XCTestCase {
    func test_fetchSymbols_mock_returnsContractList() async {
        let suite = "WWSwiftTests.ContractConfig"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let storage = UserDefaultsStorage(defaults: defaults)
        let environment = EnvironmentManager(storage: storage)
        environment.setCurrent(.mock)
        let session = SessionStore(storage: storage)
        let apiClient = APIClient(environment: environment, session: session)
        let service = ContractConfigService(apiClient: apiClient)

        let result = await service.fetchSymbols()

        guard case .success(let symbols) = result else {
            return XCTFail("Expected success")
        }
        XCTAssertEqual(symbols.count, 2)
        XCTAssertEqual(symbols.first?.contractId, "10000001")
        XCTAssertEqual(symbols.first?.symbolName, "BTC/USDT")
    }
}
