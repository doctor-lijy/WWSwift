import UIKit
import SnapKit

final class ContractOrderBookView: UIView {
    private let asksStack = UIStackView()
    private let lastPriceLabel = UILabel()
    private let bidsStack = UIStackView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.text = "盘口"
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        asksStack.axis = .vertical
        asksStack.spacing = 2
        bidsStack.axis = .vertical
        bidsStack.spacing = 2

        lastPriceLabel.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
        lastPriceLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, asksStack, lastPriceLabel, bidsStack])
        stack.axis = .vertical
        stack.spacing = 4
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(snapshot: ContractOrderBookSnapshot) {
        asksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bidsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        snapshot.asks.reversed().forEach { level in
            asksStack.addArrangedSubview(makeRow(price: level.price, size: level.size, color: .systemRed))
        }
        lastPriceLabel.text = snapshot.lastPrice
        snapshot.bids.forEach { level in
            bidsStack.addArrangedSubview(makeRow(price: level.price, size: level.size, color: .systemGreen))
        }
    }

    private func makeRow(price: String, size: String, color: UIColor) -> UIView {
        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        priceLabel.textColor = color
        let sizeLabel = UILabel()
        sizeLabel.text = size
        sizeLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        sizeLabel.textColor = .secondaryLabel
        sizeLabel.textAlignment = .right

        let row = UIStackView(arrangedSubviews: [priceLabel, sizeLabel])
        row.axis = .horizontal
        row.distribution = .fillEqually
        return row
    }
}
