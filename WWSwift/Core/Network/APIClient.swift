import Foundation
import PHNet

struct APIResponseDTO<T: Decodable>: Decodable {
    let code: Int
    let msg: String
    let data: T?
}

struct LogoutResponseDTO: Decodable {
    let code: Int
    let msg: String
}

/// HTTP 客户端。两条路径：
/// - `environment.current == .mock`：走 `MockProvider`，返回本地 JSON
/// - 其它：走 PHNet `WeexHttpClient.postJson`，由 PHNet 的 `configHeader`/`errorCallback` 统一注入签名与处理鉴权
///
/// `WeexHttpClient` 的回调返回 `TNetResponse { code, msg, data }`，`data` 是 JSON 字符串，
/// 这里把 `data` 字段再解析成 `<T>` 期望的最外层 DTO 形态（DTO 自带 `code/msg/data`，data 透传）。
final class APIClient {
    private let environment: EnvironmentManager
    private let session: SessionStore
    private let mockProvider: MockProvider

    init(
        environment: EnvironmentManager,
        session: SessionStore,
        mockProvider: MockProvider = MockProvider()
    ) {
        self.environment = environment
        self.session = session
        self.mockProvider = mockProvider
    }

    func post<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        if environment.current == .mock {
            let data = try mockProvider.data(forPath: path)
            return try JSONDecoder().decode(T.self, from: data)
        }
        return try await postViaPHNet(path: path, body: body)
    }

    // MARK: - PHNet bridge

    private func postViaPHNet<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        let url = environment.url(for: path).absoluteString
        // PHNet 的 NSObject 字典约束：剔除非 NSObject 兼容键
        let params: [String: NSObject] = body.compactMapValues { $0 as? NSObject }

        let resp: TNetResponse = await withCheckedContinuation { continuation in
            WeexHttpClient.getInstance().postJson(url, params: params) { response in
                continuation.resume(returning: response)
            }
        }

        // PHNet 的 TNetResponse 已经把 HTTP 层处理完；这里把它重新拼成 DTO 期望的 { code, msg, data } JSON
        let envelope: [String: Any] = [
            "code": resp.code,
            "msg": resp.msg ?? "",
            "data": Self.parseJSON(resp.data) as Any
        ]
        let data = try JSONSerialization.data(withJSONObject: envelope)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// 把 PHNet 的 `data: NSString` 字段解析回 JSON 对象（dict/array/null）。
    /// 若 data 为空字符串或非 JSON，则返回 `NSNull` 以保留键。
    private static func parseJSON(_ raw: String?) -> Any {
        guard let raw = raw, !raw.isEmpty, let d = raw.data(using: .utf8) else {
            return NSNull()
        }
        return (try? JSONSerialization.jsonObject(with: d)) ?? NSNull()
    }
}
