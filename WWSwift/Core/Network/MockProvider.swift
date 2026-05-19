import Foundation

struct MockProvider {
    private let bundle: Bundle
    private let overrides: [String: Data]

    init(bundle: Bundle = .main, overrides: [String: Data] = [:]) {
        self.bundle = bundle
        self.overrides = overrides
    }

    func data(forPath path: String) throws -> Data {
        if let data = overrides[path] {
            return data
        }
        let fileName = path
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        guard let url = bundle.url(forResource: fileName, withExtension: "json", subdirectory: "Mocks") else {
            throw APIError(code: 404, message: "Mock not found: \(path)", isNetworkError: false)
        }
        return try Data(contentsOf: url)
    }
}
