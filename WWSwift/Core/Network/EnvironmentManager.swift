import Foundation
import PHNet

/// 环境管理。`current` 仅落 UserDefaults；真实环境切换由本类同步到 PHNet `DomainManager`。
///
/// 设计要点：
/// - `mock` 不下发到 PHNet；保留作为本地短路开关
/// - test/stg/prod → PHNet `AppENV`
/// - `url(for:)`：mock 时返回伪域名占位（不会被真正请求）；非 mock 时调 `DomainManager.getRealUrl_New(_:)`
final class EnvironmentManager {
    static let currentEnvKey = "currentEnv"
    private static let mockBaseURL = URL(string: "https://mock.wwswift.local")!

    private let storage: KeyValueStorage

    init(storage: KeyValueStorage = UserDefaultsStorage()) {
        self.storage = storage
        if storage.string(forKey: Self.currentEnvKey) == nil {
            setCurrent(.mock, syncToPHNet: false)
        }
    }

    var current: AppEnvironment {
        let raw = storage.string(forKey: Self.currentEnvKey) ?? AppEnvironment.mock.rawValue
        return AppEnvironment(rawValue: raw) ?? .mock
    }

    /// 切换环境。`syncToPHNet=true` 时同步调用 `DomainManager.switch(_:)`，
    /// 单元测试默认走 false 以避免触碰 PHNet（PHNet 未初始化时调用 switch 会崩）。
    func setCurrent(_ env: AppEnvironment, syncToPHNet: Bool = true) {
        storage.set(env.rawValue, forKey: Self.currentEnvKey)
        guard syncToPHNet, env != .mock else { return }
        let envType = AppENV(rawValue: UInt(env.phnetEnvRawValue))
        DomainManager.getInstance().`switch`(envType)
    }

    /// 根据 path 构造完整 URL：
    /// - mock：返回 `https://mock.wwswift.local/<path>`（仅占位）
    /// - 其它：转发到 PHNet `DomainManager.getRealUrl_New(_:)`
    func url(for path: String) -> URL {
        if current == .mock {
            let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
            return Self.mockBaseURL.appendingPathComponent(trimmed)
        }
        let realPath = path.hasPrefix("/") ? path : "/" + path
        let full = DomainManager.getRealUrl_New(realPath) ?? ""
        return URL(string: full) ?? Self.mockBaseURL
    }
}
