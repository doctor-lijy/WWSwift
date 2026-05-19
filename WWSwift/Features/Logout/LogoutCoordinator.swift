import UIKit

final class LogoutCoordinator {
    private weak var presentingViewController: UIViewController?
    private let logoutService: LogoutService
    private var loadingIndicator: UIActivityIndicatorView?

    init(presentingViewController: UIViewController, logoutService: LogoutService) {
        self.presentingViewController = presentingViewController
        self.logoutService = logoutService
    }

    func performLogout() async {
        guard let viewController = presentingViewController else { return }

        await MainActor.run {
            showLoading(on: viewController)
        }

        let result = await logoutService.logout()

        await MainActor.run {
            hideLoading()
            switch result {
            case .success:
                showAlert(
                    on: viewController,
                    title: "退出",
                    message: "已成功退出登录"
                )
            case .failure(let error):
                showAlert(
                    on: viewController,
                    title: "退出失败",
                    message: error.message
                )
            }
        }
    }

    private func showLoading(on viewController: UIViewController) {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        viewController.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        loadingIndicator = indicator
    }

    private func hideLoading() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
    }

    private func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}
