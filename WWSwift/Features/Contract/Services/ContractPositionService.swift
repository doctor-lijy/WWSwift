import Foundation

struct SimpleAPIResponseDTO: Decodable {
    let code: Int
    let msg: String
}

final class ContractPositionService {
    static let cancelOrderPath = "api/v1/private/order/cancelOrderById"
    static let updateLimitPricePath = "api/v1/private/order/updateOrderLimitPrice"
    static let updateTriggerPricePath = "api/v1/private/order/updateOrderTriggerPrice"
    static let closeAllPositionPath = "api/v1/private/order/closeAllPosition"

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func cancelOrder(orderId: String) async -> Result<Void, APIError> {
        await postEmpty(path: Self.cancelOrderPath, body: ["orderIdList": [orderId]])
    }

    func updateLimitPrice(orderId: String, price: String) async -> Result<Void, APIError> {
        await postEmpty(
            path: Self.updateLimitPricePath,
            body: ["orderId": orderId, "updatePrice": price]
        )
    }

    func updateTriggerPrice(orderId: String, triggerPrice: String) async -> Result<Void, APIError> {
        await postEmpty(
            path: Self.updateTriggerPricePath,
            body: ["orderId": orderId, "triggerPrice": triggerPrice]
        )
    }

    func closeAllPositions(contractId: String) async -> Result<Void, APIError> {
        await postEmpty(
            path: Self.closeAllPositionPath,
            body: [
                "orderSource": "APP",
                "filterContractIdList": [contractId],
                "extraDataJson": "{\"costRatio\":\"100\"}"
            ]
        )
    }

    private func postEmpty(path: String, body: [String: Any]) async -> Result<Void, APIError> {
        do {
            let response: SimpleAPIResponseDTO = try await apiClient.post(path: path, body: body)
            guard response.code == 0 else {
                return .failure(APIError(code: response.code, message: response.msg, isNetworkError: false))
            }
            return .success(())
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(APIError.network(error))
        }
    }
}
