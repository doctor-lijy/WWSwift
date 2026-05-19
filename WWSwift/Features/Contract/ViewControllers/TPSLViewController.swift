import UIKit
import SnapKit

final class TPSLViewController: UIViewController {
    var onSubmit: ((String) -> Void)?

    private let titleText: String
    private let triggerField = UITextField()

    init(title: String, defaultTriggerPrice: String = "") {
        self.titleText = title
        super.init(nibName: nil, bundle: nil)
        triggerField.text = defaultTriggerPrice
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "止盈止损"
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

        triggerField.borderStyle = .roundedRect
        triggerField.keyboardType = .decimalPad
        triggerField.placeholder = "触发价格"

        let label = UILabel()
        label.text = titleText
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [label, triggerField])
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
        guard let price = triggerField.text, !price.isEmpty else { return }
        onSubmit?(price)
        dismiss(animated: true)
    }
}
