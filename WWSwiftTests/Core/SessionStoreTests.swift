import XCTest
@testable import WWSwift

final class SessionStoreTests: XCTestCase {
    func test_clear_removesTokenAndUserId() {
        let defaults = UserDefaults(suiteName: "WWSwiftTests.SessionStore")!
        defaults.removePersistentDomain(forName: "WWSwiftTests.SessionStore")
        let storage = UserDefaultsStorage(defaults: defaults)
        let store = SessionStore(storage: storage)
        store.accessToken = "abc"
        store.userId = "u1"
        store.clear()
        XCTAssertFalse(store.isLoggedIn)
        XCTAssertNil(store.userId)
    }
}
