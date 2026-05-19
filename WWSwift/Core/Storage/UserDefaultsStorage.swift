import Foundation

protocol KeyValueStorage {
    func string(forKey key: String) -> String?
    func set(_ value: String?, forKey key: String)
    func integer(forKey key: String) -> Int
    func set(_ value: Int, forKey key: String)
}

struct UserDefaultsStorage: KeyValueStorage {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func set(_ value: String?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func integer(forKey key: String) -> Int {
        defaults.integer(forKey: key)
    }

    func set(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
