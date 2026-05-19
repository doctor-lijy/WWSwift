import XCTest
@testable import WWSwift

final class EnvironmentManagerTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "WWSwiftTests.EnvironmentManager")!
        defaults.removePersistentDomain(forName: "WWSwiftTests.EnvironmentManager")
    }

    func test_defaultEnvironment_isMock() {
        let manager = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        XCTAssertEqual(manager.current, .mock)
    }

    func test_switchEnvironment_persists() {
        let manager = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        // 不下发 PHNet，避免测试环境下触碰未配置的 DomainManager
        manager.setCurrent(.test, syncToPHNet: false)
        let reloaded = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        XCTAssertEqual(reloaded.current, .test)
    }

    func test_mockUrl_isLocalPlaceholder() {
        let manager = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        XCTAssertEqual(
            manager.url(for: "api/v1/public/meta/getMetaDataNew").absoluteString,
            "https://mock.wwswift.local/api/v1/public/meta/getMetaDataNew"
        )
    }
}
