import UIKit
import SnapKit

final class ContractHeaderView: UIView {
    var onSwitchSymbolTapped: (() -> Void)?

    private let symbolLabel = UILabel()
    private let perpetualBadge = UILabel()
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
        priceLabel.text = lastPrice ?? "—"

        guard let raw = priceChangePercent, let value = Double(raw) else {
            changeLabel.text = "—"
            changeLabel.textColor = .secondaryLabel
            return
        }
        let pct = value * 100
        let sign = pct >= 0 ? "+" : ""
        changeLabel.text = String(format: "%@%.2f%%", sign, pct)
        changeLabel.textColor = pct >= 0 ? .systemGreen : .systemRed
    }

    func updateSocketStatus(_ connected: Bool) {
        socketDotView.backgroundColor = connected ? .systemGreen : .systemGray3
    }

    private func setup() {
        symbolLabel.font = .boldSystemFont(ofSize: 18)
        perpetualBadge.text = "永续"
        perpetualBadge.font = .systemFont(ofSize: 11, weight: .medium)
        perpetualBadge.textColor = .secondaryLabel
        perpetualBadge.backgroundColor = .secondarySystemFill
        perpetualBadge.layer.cornerRadius = 4
        perpetualBadge.clipsToBounds = true
        perpetualBadge.textAlignment = .center

        priceLabel.font = .monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
        changeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        switchButton.setTitle("切换", for: .normal)
        switchButton.addAction(UIAction { [weak self] _ in
            self?.onSwitchSymbolTapped?()
        }, for: .touchUpInside)

        socketDotView.layer.cornerRadius = 4
        socketDotView.backgroundColor = .systemGray3

        addSubview(symbolLabel)
        addSubview(perpetualBadge)
        addSubview(socketDotView)
        addSubview(switchButton)
        addSubview(priceLabel)
        addSubview(changeLabel)

        symbolLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 0))
        }
        perpetualBadge.snp.makeConstraints { make in
            make.leading.equalTo(symbolLabel.snp.trailing).offset(6)
            make.centerY.equalTo(symbolLabel)
            make.width.greaterThanOrEqualTo(36)
            make.height.equalTo(20)
        }
        socketDotView.snp.makeConstraints { make in
            make.leading.equalTo(perpetualBadge.snp.trailing).offset(8)
            make.centerY.equalTo(symbolLabel)
            make.size.equalTo(8)
        }
        switchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(symbolLabel)
        }
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(symbolLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(8)
        }
        changeLabel.snp.makeConstraints { make in
            make.leading.equalTo(priceLabel.snp.trailing).offset(8)
            make.centerY.equalTo(priceLabel)
        }
    }
}
