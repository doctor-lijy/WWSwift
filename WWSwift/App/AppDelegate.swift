import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    let session = SessionStore()
    let environment = EnvironmentManager()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        PHNetBootstrap.configure(session: session, environment: environment)

        ContractMarketSocketService.shared.registerReceivers()
        ContractOrderBookSocketService.shared.registerReceivers()
        ContractPrivateTradeSocketService.shared.registerReceivers()
        SocketBootstrap.start()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        SocketBootstrap.onAppForeground()
    }
}
