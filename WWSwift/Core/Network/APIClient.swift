import Foundation

struct APIResponseDTO<T: Decodable>: Decodable {
    let code: Int
    let msg: String
    let data: T?
}

struct LogoutResponseDTO: Decodable {
    let code: Int
    let msg: String
}

final class APIClient {
    private let environment: EnvironmentManager
    private let session: SessionStore
    private let mockProvider: MockProvider
    private let urlSession: URLSession

    init(
        environment: EnvironmentManager,
        session: SessionStore,
        mockProvider: MockProvider = MockProvider(),
        urlSession: URLSession = .shared
    ) {
        self.environment = environment
        self.session = session
        self.mockProvider = mockProvider
        self.urlSession = urlSession
    }

    func post<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        if environment.current == .mock {
            let data = try mockProvider.data(forPath: path)
            return try JSONDecoder().decode(T.self, from: data)
        }
        let signed = RequestSigning.signedParameters(body, token: session.accessToken)
        var request = URLRequest(url: environment.url(for: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: signed)
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError(code: -1, message: "HTTP error", isNetworkError: true)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
