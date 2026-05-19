import Foundation

/// 用户会话存储。字段命名与 weexios `UserManger` 对齐：
/// - `accessToken`：登录返回的 access token，HTTP header `u-token`
/// - `userToken`：业务 token，HTTP header `token`；isLogin 以此判定
/// - `rToken`：刷新 token，Socket header `X-TOKEN`
final class SessionStore {
    static let accessTokenKey = "SP_KEY_TOKEN"
    static let userTokenKey = "SP_KEY_USER_TOKEN"
    static let rTokenKey = "SP_KEY_R_TOKEN"
    static let userIdKey = "SP_KEY_USER_ID"

    private let storage: KeyValueStorage

    init(storage: KeyValueStorage = UserDefaultsStorage()) {
        self.storage = storage
    }

    var accessToken: String? {
        get { storage.string(forKey: Self.accessTokenKey) }
        set { storage.set(newValue, forKey: Self.accessTokenKey) }
    }

    var userToken: String? {
        get { storage.string(forKey: Self.userTokenKey) }
        set { storage.set(newValue, forKey: Self.userTokenKey) }
    }

    var rToken: String? {
        get { storage.string(forKey: Self.rTokenKey) }
        set { storage.set(newValue, forKey: Self.rTokenKey) }
    }

    var userId: String? {
        get { storage.string(forKey: Self.userIdKey) }
        set { storage.set(newValue, forKey: Self.userIdKey) }
    }

    /// 对齐 weexios `UserManger.isLogin`：以 userToken 非空判定
    var isLoggedIn: Bool {
        guard let token = userToken else { return false }
        return !token.isEmpty
    }

    func clear() {
        accessToken = nil
        userToken = nil
        rToken = nil
        userId = nil
    }
}
