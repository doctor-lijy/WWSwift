import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let environmentManager = EnvironmentManager()
        let sessionStore = SessionStore()
        let apiClient = APIClient(environment: environmentManager, session: sessionStore)
        let viewModel = ContractViewModel(
            configService: ContractConfigService(apiClient: apiClient),
            tradingService: ContractTradingService(apiClient: apiClient),
            environmentManager: environmentManager
        )
        let contract = UINavigationController(
            rootViewController: ContractViewController(viewModel: viewModel)
        )
        contract.tabBarItem = UITabBarItem(title: "合约", image: nil, tag: 0)

        #if DEBUG
        let debug = UINavigationController(rootViewController: EnvironmentDebugViewController())
        debug.tabBarItem = UITabBarItem(title: "Debug", image: nil, tag: 1)
        viewControllers = [contract, debug]
        #else
        viewControllers = [contract]
        #endif
    }
}
