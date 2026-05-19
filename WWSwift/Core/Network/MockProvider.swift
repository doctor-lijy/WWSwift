import Foundation

struct MockProvider {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func data(forPath path: String) throws -> Data {
        let fileName = path
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        guard let url = bundle.url(forResource: fileName, withExtension: "json", subdirectory: "Mocks") else {
            throw APIError(code: 404, message: "Mock not found: \(path)", isNetworkError: false)
        }
        return try Data(contentsOf: url)
    }
}
