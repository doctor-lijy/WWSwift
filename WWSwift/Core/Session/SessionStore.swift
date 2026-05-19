import Foundation

final class SessionStore {
    static let tokenKey = "SP_KEY_TOKEN"
    static let userIdKey = "SP_KEY_USER_ID"

    private let storage: KeyValueStorage

    init(storage: KeyValueStorage = UserDefaultsStorage()) {
        self.storage = storage
    }

    var accessToken: String? {
        get { storage.string(forKey: Self.tokenKey) }
        set { storage.set(newValue, forKey: Self.tokenKey) }
    }

    var userId: String? {
        get { storage.string(forKey: Self.userIdKey) }
        set { storage.set(newValue, forKey: Self.userIdKey) }
    }

    var isLoggedIn: Bool {
        guard let token = accessToken else { return false }
        return !token.isEmpty
    }

    func clear() {
        accessToken = nil
        userId = nil
    }
}
