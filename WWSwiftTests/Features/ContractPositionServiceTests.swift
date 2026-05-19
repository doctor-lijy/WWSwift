import XCTest
@testable import WWSwift

final class ContractPositionServiceTests: XCTestCase {
    private func makeService() -> ContractPositionService {
        let suite = "WWSwiftTests.ContractPositionService"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let storage = UserDefaultsStorage(defaults: defaults)
        let environment = EnvironmentManager(storage: storage)
        environment.setCurrent(.mock)
        let session = SessionStore(storage: storage)
        let apiClient = APIClient(environment: environment, session: session)
        return ContractPositionService(apiClient: apiClient)
    }

    func test_cancelOrder_mock_success() async {
        let result = await makeService().cancelOrder(orderId: "mock-order-1")
        guard case .success = result else {
            return XCTFail("Expected success")
        }
    }

    func test_closeAllPositions_mock_success() async {
        let result = await makeService().closeAllPositions(contractId: "10000001")
        guard case .success = result else {
            return XCTFail("Expected success")
        }
    }
}
