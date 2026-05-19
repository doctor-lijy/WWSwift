import Foundation

enum AppEnvironment: String, CaseIterable, Codable {
    case mock
    case test
    case stg
    case prod

    var displayName: String {
        switch self {
        case .mock: return "Mock"
        case .test: return "Test (T3)"
        case .stg: return "STG"
        case .prod: return "Prod"
        }
    }
}
