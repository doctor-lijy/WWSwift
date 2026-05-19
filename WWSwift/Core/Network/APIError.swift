import Foundation

struct APIError: Error, Equatable {
    let code: Int
    let message: String
    let isNetworkError: Bool

    static func network(_ underlying: Error) -> APIError {
        APIError(code: -1, message: underlying.localizedDescription, isNetworkError: true)
    }
}
