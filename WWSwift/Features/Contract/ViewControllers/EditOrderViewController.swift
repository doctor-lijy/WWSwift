import UIKit
import SnapKit

final class EditOrderViewController: UIViewController {
    var onSubmit: ((String) -> Void)?

    private let order: ContractOrder
    private let priceField = UITextField()

    init(order: ContractOrder) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改限价"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "保存",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )

        priceField.borderStyle = .roundedRect
        priceField.keyboardType = .decimalPad
        priceField.placeholder = "新价格"
        priceField.text = order.price

        let label = UILabel()
        label.text = order.displayTitle
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [label, priceField])
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let price = priceField.text, !price.isEmpty else { return }
        onSubmit?(price)
        dismiss(animated: true)
    }
}
