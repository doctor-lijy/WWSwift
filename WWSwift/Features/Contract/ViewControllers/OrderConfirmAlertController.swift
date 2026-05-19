import UIKit

enum OrderConfirmAlertController {
    @MainActor
    static func present(
        from viewController: UIViewController,
        request: PlaceOrderRequest,
        onConfirm: @escaping () -> Void
    ) {
        let message = """
        合约: \(request.contractId)
        \(request.summaryText)
        """
        let alert = UIAlertController(title: "确认下单", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认", style: .default) { _ in
            onConfirm()
        })
        viewController.present(alert, animated: true)
    }
}
