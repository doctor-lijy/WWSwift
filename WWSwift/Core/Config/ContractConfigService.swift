import Foundation

struct ContractSymbolDTO: Decodable {
    let contractId: String
    let contractName: String
}

struct ContractMetaDataDTO: Decodable {
    let contractList: [ContractSymbolDTO]
}

struct ContractMetaResponseDTO: Decodable {
    let code: Int
    let msg: String
    let data: ContractMetaDataDTO?
}

final class ContractConfigService {
    static let metaPath = "api/v1/public/meta/getMetaDataNew"

    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchSymbols() async -> Result<[ContractSymbol], APIError> {
        do {
            let response: ContractMetaResponseDTO = try await apiClient.post(
                path: Self.metaPath,
                body: [:]
            )
            guard response.code == 0 else {
                return .failure(APIError(code: response.code, message: response.msg, isNetworkError: false))
            }
            let symbols = response.data?.contractList.map {
                ContractSymbol(contractId: $0.contractId, symbolName: $0.contractName)
            } ?? []
            return .success(symbols)
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(APIError.network(error))
        }
    }
}
