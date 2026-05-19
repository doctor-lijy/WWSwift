import Foundation

final class LogoutService {
    private let apiClient: APIClient
    private let session: SessionStore
    private let sideEffects: LogoutSideEffectRegistry

    init(
        apiClient: APIClient,
        session: SessionStore,
        sideEffects: LogoutSideEffectRegistry = LogoutSideEffectRegistry()
    ) {
        self.apiClient = apiClient
        self.session = session
        self.sideEffects = sideEffects
    }

    func logout() async -> Result<Void, APIError> {
        do {
            let response: LogoutResponseDTO = try await apiClient.post(
                path: "v1/user/login/logout",
                body: [:]
            )
            guard response.code == 0 else {
                return .failure(APIError(code: response.code, message: response.msg, isNetworkError: false))
            }
            session.clear()
            sideEffects.performAfterLogout()
            return .success(())
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(APIError.network(error))
        }
    }
}
