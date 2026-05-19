import UIKit
import SnapKit

final class ContractHeaderView: UIView {
    var onSwitchSymbolTapped: (() -> Void)?

    private let symbolLabel = UILabel()
    private let switchButton = UIButton(type: .system)
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    private let socketDotView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(symbolName: String) {
        symbolLabel.text = symbolName
    }

    func updateTicker(lastPrice: String?, priceChangePercent: String?) {
        priceLabel.text = lastPrice.map { "$\($0)" } ?? "—"

        guard let raw = priceChangePercent, let value = Double(raw) else {
            changeLabel.text = "—"
            changeLabel.textColor = .secondaryLabel
            return
        }
        let pct = value * 100
        let sign = pct >= 0 ? "+" : ""
        changeLabel.text = String(format: "%@%.2f%%", sign, pct)
        changeLabel.textColor = pct >= 0
            ? UIColor.systemGreen
            : UIColor.systemRed
    }

    func updateSocketStatus(_ connected: Bool) {
        socketDotView.backgroundColor = connected ? .systemGreen : .systemGray3
    }

    private func setup() {
        symbolLabel.font = .boldSystemFont(ofSize: 20)
        priceLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        priceLabel.textColor = .label
        changeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        changeLabel.textColor = .secondaryLabel
        switchButton.setTitle("切换币对", for: .normal)
        switchButton.addAction(UIAction { [weak self] _ in
            self?.onSwitchSymbolTapped?()
        }, for: .touchUpInside)

        socketDotView.layer.cornerRadius = 4
        socketDotView.backgroundColor = .systemGray3

        addSubview(symbolLabel)
        addSubview(socketDotView)
        addSubview(switchButton)
        addSubview(priceLabel)
        addSubview(changeLabel)

        symbolLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(10)
        }
        socketDotView.snp.makeConstraints { make in
            make.leading.equalTo(symbolLabel.snp.trailing).offset(8)
            make.centerY.equalTo(symbolLabel)
            make.size.equalTo(CGSize(width: 8, height: 8))
        }
        switchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(symbolLabel)
        }
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(symbolLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(10)
        }
        changeLabel.snp.makeConstraints { make in
            make.leading.equalTo(priceLabel.snp.trailing).offset(10)
            make.centerY.equalTo(priceLabel)
        }
        snp.makeConstraints { make in
            make.height.equalTo(72)
        }
    }
}
