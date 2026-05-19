import UIKit
import SnapKit

final class LeverageBarView: UIView {
    var onAdjustTapped: (() -> Void)?

    private let leverageLabel = UILabel()
    private let marginLabel = UILabel()
    private let adjustButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(leverage: Int, marginMode: ContractMarginMode) {
        leverageLabel.text = "\(leverage)x"
        marginLabel.text = marginMode.displayTitle
    }

    private func setup() {
        leverageLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        marginLabel.font = .systemFont(ofSize: 13)
        marginLabel.textColor = .secondaryLabel
        adjustButton.setTitle("调整", for: .normal)
        adjustButton.titleLabel?.font = .systemFont(ofSize: 13)
        adjustButton.addAction(UIAction { [weak self] _ in
            self?.onAdjustTapped?()
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [leverageLabel, marginLabel, UIView(), adjustButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
            make.height.equalTo(32)
        }
    }
}
