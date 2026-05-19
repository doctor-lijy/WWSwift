import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let contract = UINavigationController(rootViewController: ContractPlaceholderViewController())
        contract.tabBarItem = UITabBarItem(title: "合约", image: nil, tag: 0)

        #if DEBUG
        let debug = UINavigationController(rootViewController: DebugPlaceholderViewController())
        debug.tabBarItem = UITabBarItem(title: "Debug", image: nil, tag: 1)
        viewControllers = [contract, debug]
        #else
        viewControllers = [contract]
        #endif
    }
}

/// P2 替换为真实 ContractViewController
final class ContractPlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "合约"
        let label = UILabel()
        label.text = "合约页 — P2 落地"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

#if DEBUG
final class DebugPlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Debug"
        let label = UILabel()
        label.text = "Debug — Task 5"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
#endif
