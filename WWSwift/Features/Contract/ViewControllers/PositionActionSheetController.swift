import UIKit

enum PositionActionSheetController {
    @MainActor
    static func present(
        from viewController: UIViewController,
        position: ContractPosition,
        onCloseAll: @escaping () -> Void,
        onTPSL: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "仓位操作",
            message: position.displayTitle,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "一键平仓", style: .destructive) { _ in onCloseAll() })
        alert.addAction(UIAlertAction(title: "止盈止损", style: .default) { _ in onTPSL() })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 1, height: 1)
        }
        viewController.present(alert, animated: true)
    }
}
