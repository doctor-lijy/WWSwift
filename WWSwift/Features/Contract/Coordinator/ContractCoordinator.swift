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

    func handleRowSelection(at index: Int, from viewController: UIViewController) {
        switch viewModel.segment {
        case .positions:
            guard let position = viewModel.position(at: index) else { return }
            PositionActionSheetController.present(
                from: viewController,
                position: position,
                onCloseAll: { [weak self] in
                    self?.runAction(from: viewController) {
                        await self?.viewModel.closeAllPositions(for: position)
                    }
                },
                onTPSL: { [weak self] in
                    self?.presentTPSL(from: viewController, title: position.displayTitle, orderId: nil)
                }
            )
        case .activeOrders:
            guard let order = viewModel.order(at: index) else { return }
            presentOrderActions(order: order, from: viewController)
        }
    }

    private func presentOrderActions(order: ContractOrder, from viewController: UIViewController) {
        let alert = UIAlertController(title: "委托操作", message: order.displayTitle, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "撤单", style: .destructive) { [weak self] _ in
            self?.runAction(from: viewController) {
                await self?.viewModel.cancelOrder(orderId: order.orderId)
            }
        })
        alert.addAction(UIAlertAction(title: "改价", style: .default) { [weak self] _ in
            self?.presentEditOrder(order: order, from: viewController)
        })
        alert.addAction(UIAlertAction(title: "止盈止损", style: .default) { [weak self] _ in
            self?.presentTPSL(from: viewController, title: order.displayTitle, orderId: order.orderId)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 1, height: 1)
        }
        viewController.present(alert, animated: true)
    }

    private func presentEditOrder(order: ContractOrder, from viewController: UIViewController) {
        let editVC = EditOrderViewController(order: order)
        editVC.onSubmit = { [weak self] price in
            self?.runAction(from: viewController) {
                await self?.viewModel.updateOrderLimitPrice(orderId: order.orderId, price: price)
            }
        }
        let nav = UINavigationController(rootViewController: editVC)
        viewController.present(nav, animated: true)
    }

    private func presentTPSL(from viewController: UIViewController, title: String, orderId: String?) {
        let tpslVC = TPSLViewController(title: title)
        tpslVC.onSubmit = { [weak self] triggerPrice in
            guard let self, let orderId else {
                self?.showToast(on: viewController, message: "已设置触发价 \(triggerPrice)（仓位 TP/SL 占位）")
                return
            }
            self.runAction(from: viewController) {
                await self.viewModel.updateOrderTriggerPrice(orderId: orderId, triggerPrice: triggerPrice)
            }
        }
        let nav = UINavigationController(rootViewController: tpslVC)
        viewController.present(nav, animated: true)
    }

    private func runAction(from viewController: UIViewController, _ work: @escaping () async -> Result<Void, APIError>?) {
        Task {
            guard let result = await work() else { return }
            await MainActor.run {
                switch result {
                case .success:
                    self.showToast(on: viewController, message: "操作成功")
                case .failure(let error):
                    self.showToast(on: viewController, message: error.message)
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
