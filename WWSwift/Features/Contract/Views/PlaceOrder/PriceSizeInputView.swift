import UIKit
import SnapKit

final class PriceSizeInputView: UIView {
    var onSizeChanged: ((String) -> Void)?

    let priceField = UITextField()
    let sizeField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        priceField.placeholder = "价格"
        sizeField.placeholder = "数量"
        [priceField, sizeField].forEach {
            $0.borderStyle = .roundedRect
            $0.font = .systemFont(ofSize: 14)
        }
        priceField.keyboardType = .decimalPad
        sizeField.keyboardType = .decimalPad
        sizeField.addAction(UIAction { [weak self] _ in
            self?.onSizeChanged?(self?.sizeField.text ?? "")
        }, for: .editingChanged)

        let stack = UIStackView(arrangedSubviews: [priceField, sizeField])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 4, right: 12))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLimitEnabled(_ enabled: Bool) {
        priceField.isEnabled = enabled
        priceField.alpha = enabled ? 1 : 0.4
        if !enabled { priceField.text = nil }
    }

    func setSizeText(_ text: String) {
        if sizeField.text != text {
            sizeField.text = text
        }
    }
}
