import XCTest
@testable import WWSwift

final class APIClientTests: XCTestCase {
    func test_post_mockLogout_returnsOK() async throws {
        let suite = "APIClientTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let env = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        env.setCurrent(.mock)
        let session = SessionStore(storage: UserDefaultsStorage(defaults: defaults))
        session.accessToken = "test-token"
        let client = APIClient(environment: env, session: session)
        let response: LogoutResponseDTO = try await client.post(path: "v1/user/login/logout", body: [:])
        XCTAssertEqual(response.code, 0)
    }
}
