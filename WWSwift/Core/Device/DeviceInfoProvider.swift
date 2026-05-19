import Foundation
import UIKit
import CryptoKit

/// 复刻 weexios `DeviceManager` 中签名/HTTP 头所需的字段。
///
/// - `vs`：每次请求生成的随机 32 字符串，对齐 `generateVSCode`（指定位置固定字符）。
/// - `deviceID`：终端唯一码（identifierForVendor + UserDefaults 缓存）。
/// - `appVersion / build / packageName / systemVersion / deviceModel`：Bundle / UIKit 字段。
/// - `md5(_:)`：业务签名 originSIG 的 MD5。
/// - `sidecar`：透传到 PHNet 的 `SecurityManager`（私有算法，不在本工程实现）。
enum DeviceInfoProvider {
    private static let deviceIDKey = "weex_device_uuid"

    // MARK: - vs

    /// 32 字符随机串（[a-z0-9]），并在指定位置写入固定字符。
    /// 算法对齐 weexios `DeviceManager.generateVSCode`。
    static func generateVSCode() -> String {
        var chars: [Character] = (0..<32).map { _ in
            let n = Int.random(in: 0..<36)
            if n < 10 {
                let digit = Int.random(in: 0..<10)
                return Character(String(digit))
            } else {
                let code = Int.random(in: 0..<26) + 97 // 'a'..'z'
                return Character(UnicodeScalar(code)!)
            }
        }
        let fixed: [(Int, Character)] = [
            (1, "5"),
            (3, "7"),
            (7, "8"),
            (14, "9"),
            (20, "7"),
            (29, "6"),
        ]
        for (idx, ch) in fixed where chars.indices.contains(idx) {
            chars[idx] = ch
        }
        return String(chars)
    }

    // MARK: - Device ID

    static func deviceID() -> String {
        if let cached = UserDefaults.standard.string(forKey: deviceIDKey), !cached.isEmpty {
            return cached
        }
        let fresh = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(fresh, forKey: deviceIDKey)
        return fresh
    }

    // MARK: - App / OS

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }

    static var packageName: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    static var systemVersion: String {
        UIDevice.current.systemVersion
    }

    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { acc, element in
            guard let value = element.value as? Int8, value != 0 else { return acc }
            return acc + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    // MARK: - MD5

    /// 业务签名 originSIG 的 MD5（小写 hex），对齐 weexios `CocoaSecurity.md5(...).hexLower`。
    static func md5(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
