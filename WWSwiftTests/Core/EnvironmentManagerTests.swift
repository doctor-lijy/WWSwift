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
        manager.setCurrent(.test)
        let reloaded = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        XCTAssertEqual(reloaded.current, .test)
        XCTAssertTrue(reloaded.contractAPIBaseURL.absoluteString.hasPrefix("https://"))
    }
}
