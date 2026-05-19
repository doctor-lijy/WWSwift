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
}
