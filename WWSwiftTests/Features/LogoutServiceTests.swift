import XCTest
@testable import WWSwift

final class LogoutServiceTests: XCTestCase {
    private let suiteName = "WWSwiftTests.LogoutService"
    private let logoutPath = "v1/user/login/logout"

    private func makeService(
        mockOverrides: [String: Data] = [:]
    ) -> (LogoutService, SessionStore) {
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let storage = UserDefaultsStorage(defaults: defaults)
        let environment = EnvironmentManager(storage: storage)
        environment.setCurrent(.mock)
        let session = SessionStore(storage: storage)
        session.accessToken = "test-token"
        session.userId = "user-1"
        let apiClient = APIClient(
            environment: environment,
            session: session,
            mockProvider: MockProvider(overrides: mockOverrides)
        )
        let service = LogoutService(
            apiClient: apiClient,
            session: session,
            sideEffects: LogoutSideEffectRegistry(userDefaults: defaults)
        )
        return (service, session)
    }

    func test_logout_success_clearsSession() async {
        let (service, session) = makeService()
        let result = await service.logout()
        guard case .success = result else {
            return XCTFail("Expected success, got \(result)")
        }
        XCTAssertFalse(session.isLoggedIn)
        XCTAssertNil(session.userId)
    }

    func test_logout_failure_keepsSession() async {
        let failJSON = Data("{\"code\":1001,\"msg\":\"fail\"}".utf8)
        let (service, session) = makeService(mockOverrides: [logoutPath: failJSON])
        let result = await service.logout()
        guard case .failure(let error) = result else {
            return XCTFail("Expected failure")
        }
        XCTAssertEqual(error.code, 1001)
        XCTAssertTrue(session.isLoggedIn)
        XCTAssertEqual(session.accessToken, "test-token")
    }
}
