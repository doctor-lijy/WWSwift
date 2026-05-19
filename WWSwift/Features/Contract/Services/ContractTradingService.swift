import Foundation

struct ContractOrderDTO: Decodable {
    let orderId: String
    let contractId: String
    let side: String
    let size: String
    let price: String
}

struct ActiveOrderPageDTO: Decodable {
    let list: [ContractOrderDTO]
}

struct ActiveOrderResponseDTO: Decodable {
    let code: Int
    let msg: String
    let data: ActiveOrderPageDTO?
}

final class ContractTradingService {
    static let activeOrderPath = "api/v1/private/order/getActiveOrderPage"

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchActiveOrders(contractId: String) async -> Result<[ContractOrder], APIError> {
        do {
            let response: ActiveOrderResponseDTO = try await apiClient.post(
                path: Self.activeOrderPath,
                body: ["contractId": contractId, "pageNo": 1, "pageSize": 50]
            )
            guard response.code == 0 else {
                return .failure(APIError(code: response.code, message: response.msg, isNetworkError: false))
            }
            let orders = response.data?.list.map {
                ContractOrder(
                    orderId: $0.orderId,
                    contractId: $0.contractId,
                    side: $0.side,
                    size: $0.size,
                    price: $0.price
                )
            } ?? []
            return .success(orders)
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(APIError.network(error))
        }
    }
}
