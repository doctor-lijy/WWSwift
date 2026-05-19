import XCTest
@testable import WWSwift

final class ContractConfigServicePHNetTests: XCTestCase {
    func testFetchSymbols_integration_skippedByDefault() async throws {
        try XCTSkipIf(
            ProcessInfo.processInfo.environment["WWSWIFT_PHNET_IT"] != "1",
            "Set WWSWIFT_PHNET_IT=1 and inject tokens via UserDefaults to run"
        )

        let suite = "WWSwiftTests.PHNetIT"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)

        let storage = UserDefaultsStorage(defaults: defaults)
        let environment = EnvironmentManager(storage: storage)
        environment.setCurrent(.test, syncToPHNet: true)

        let session = SessionStore(storage: storage)
        if let access = ProcessInfo.processInfo.environment["WWSWIFT_ACCESS_TOKEN"] {
            session.accessToken = access
        }
        if let user = ProcessInfo.processInfo.environment["WWSWIFT_USER_TOKEN"] {
            session.userToken = user
        }
        if let rToken = ProcessInfo.processInfo.environment["WWSWIFT_R_TOKEN"] {
            session.rToken = rToken
        }

        PHNetBootstrap.configure(session: session, environment: environment)

        let apiClient = APIClient(environment: environment, session: session)
        let service = ContractConfigService(apiClient: apiClient)
        let result = await service.fetchSymbols()

        guard case .success(let symbols) = result else {
            return XCTFail("Expected success from getMetaDataNew")
        }
        XCTAssertFalse(symbols.isEmpty)
    }
}
