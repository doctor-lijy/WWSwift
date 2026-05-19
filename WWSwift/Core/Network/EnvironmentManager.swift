import Foundation

final class EnvironmentManager {
    static let currentEnvKey = "currentEnv"

    private let storage: KeyValueStorage

    init(storage: KeyValueStorage = UserDefaultsStorage()) {
        self.storage = storage
        if storage.string(forKey: Self.currentEnvKey) == nil {
            setCurrent(.mock)
        }
    }

    var current: AppEnvironment {
        let raw = storage.string(forKey: Self.currentEnvKey) ?? AppEnvironment.mock.rawValue
        return AppEnvironment(rawValue: raw) ?? .mock
    }

    func setCurrent(_ env: AppEnvironment) {
        storage.set(env.rawValue, forKey: Self.currentEnvKey)
    }

    /// 新合约 API 域名 — 对齐 DomainManager.getRealUrl_New
    var contractAPIBaseURL: URL {
        switch current {
        case .mock:
            return URL(string: "https://mock.wwswift.local")!
        case .test:
            return URL(string: "https://http-gateway1.janapw.com")!
        case .stg:
            return URL(string: "https://http-gateway1.weex.com")!
        case .prod:
            return URL(string: "https://http-gateway1.weex.com")!
        }
    }

    func url(for path: String) -> URL {
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return contractAPIBaseURL.appendingPathComponent(trimmed)
    }
}
