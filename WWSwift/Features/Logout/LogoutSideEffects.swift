import Foundation

struct LogoutSideEffectRegistry {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func performAfterLogout() {
        NotificationCenter.default.post(name: .wwUserDidLogout, object: nil)
        userDefaults.removeObject(forKey: "contract_passphrase_cache")
    }
}
