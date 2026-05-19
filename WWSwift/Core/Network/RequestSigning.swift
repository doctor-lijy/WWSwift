import Foundation

enum RequestSigning {
    static func signedParameters(_ params: [String: Any], token: String?) -> [String: Any] {
        var result = params
        result["timestamp"] = Int(Date().timeIntervalSince1970 * 1000)
        if let token, !token.isEmpty {
            result["token"] = token
        }
        result["sign"] = "TODO_P1_FULL_SIGN"
        return result
    }
}
