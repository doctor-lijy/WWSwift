import UIKit

@MainActor
final class ContractCoordinator {
    private weak var viewController: ContractViewController?
    private let viewModel: ContractViewModel

    init(viewController: ContractViewController, viewModel: ContractViewModel) {
        self.viewController = viewController
        self.viewModel = viewModel
    }

    func presentSymbolPicker(from viewController: UIViewController) {
        let alert = UIAlertController(title: "选择币对", message: nil, preferredStyle: .actionSheet)
        viewModel.symbols.forEach { symbol in
            alert.addAction(UIAlertAction(title: symbol.symbolName, style: .default) { [weak self] _ in
                Task { await self?.viewModel.selectSymbol(symbol) }
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: 80, width: 1, height: 1)
        }
        viewController.present(alert, animated: true)
    }

    func handlePlaceOrder(from viewController: UIViewController, request: PlaceOrderRequest) {
        switch request.validate() {
        case .failure(let error):
            showToast(on: viewController, message: error.localizedMessage)
            return
        case .success:
            break
        }

        OrderConfirmAlertController.present(from: viewController, request: request) { [weak self] in
            guard let self else { return }
            Task {
                let result = await self.viewModel.submitOrder(request)
                await MainActor.run {
                    switch result {
                    case .success(let orderId):
                        let suffix = orderId.isEmpty ? "" : " (\(orderId))"
                        self.showToast(on: viewController, message: "下单成功\(suffix)")
                    case .failure(let error):
                        self.showToast(on: viewController, message: error.message)
                    }
                }
            }
        }
    }

    private func showToast(on viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        viewController.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            alert.dismiss(animated: true)
        }
    }
}
