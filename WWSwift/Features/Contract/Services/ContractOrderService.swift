import Foundation

struct CreateOrderDataDTO: Decodable {
    let orderId: String?
}

struct CreateOrderResponseDTO: Decodable {
    let code: Int
    let msg: String
    let data: CreateOrderDataDTO?
}

final class ContractOrderService {
    static let createOrderPath = "api/v1/private/order/createOrder"

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func placeOrder(_ request: PlaceOrderRequest) async -> Result<String, APIError> {
        switch request.validate() {
        case .failure(let validationError):
            return .failure(APIError(code: -2, message: validationError.localizedMessage, isNetworkError: false))
        case .success:
            break
        }

        do {
            let response: CreateOrderResponseDTO = try await apiClient.post(
                path: Self.createOrderPath,
                body: request.apiParameters()
            )
            guard response.code == 0 else {
                return .failure(APIError(code: response.code, message: response.msg, isNetworkError: false))
            }
            return .success(response.data?.orderId ?? "")
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(APIError.network(error))
        }
    }
}
