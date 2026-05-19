import UIKit
import SnapKit

final class PlaceOrderButtonsView: UIView {
    var onBuyLong: (() -> Void)?
    var onSellShort: (() -> Void)?

    private let buyButton = UIButton(type: .system)
    private let sellButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure(button: buyButton, title: "买入开多", color: .systemGreen)
        configure(button: sellButton, title: "卖出开空", color: .systemRed)
        buyButton.addAction(UIAction { [weak self] _ in self?.onBuyLong?() }, for: .touchUpInside)
        sellButton.addAction(UIAction { [weak self] _ in self?.onSellShort?() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [buyButton, sellButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 8, right: 12))
            make.height.equalTo(44)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitles(openMode: OpenCloseMode) {
        switch openMode {
        case .open:
            buyButton.setTitle("买入开多", for: .normal)
            sellButton.setTitle("卖出开空", for: .normal)
        case .close:
            buyButton.setTitle("买入平空", for: .normal)
            sellButton.setTitle("卖出平多", for: .normal)
        }
    }

    private func configure(button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    }
}
