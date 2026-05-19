import UIKit
import SnapKit

final class EmptyStateView: UIView {
    var onDepositTapped: (() -> Void)?
    var onTransferTapped: (() -> Void)?

    private let messageLabel = UILabel()
    private let depositButton = UIButton(type: .system)
    private let transferButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        messageLabel.text = "暂无数据"
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        depositButton.setTitle("充值", for: .normal)
        transferButton.setTitle("划转", for: .normal)
        depositButton.addAction(UIAction { [weak self] _ in self?.onDepositTapped?() }, for: .touchUpInside)
        transferButton.addAction(UIAction { [weak self] _ in self?.onTransferTapped?() }, for: .touchUpInside)

        let buttons = UIStackView(arrangedSubviews: [depositButton, transferButton])
        buttons.axis = .horizontal
        buttons.spacing = 24
        buttons.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [messageLabel, buttons])
        stack.axis = .vertical
        stack.spacing = 12
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMessage(_ text: String) {
        messageLabel.text = text
    }
}
