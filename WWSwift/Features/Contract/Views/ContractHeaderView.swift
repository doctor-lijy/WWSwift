import UIKit
import SnapKit

final class ContractHeaderView: UIView {
    var onSwitchSymbolTapped: (() -> Void)?

    private let symbolLabel = UILabel()
    private let switchButton = UIButton(type: .system)

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

    private func setup() {
        symbolLabel.font = .boldSystemFont(ofSize: 20)
        switchButton.setTitle("切换币对", for: .normal)
        switchButton.addAction(UIAction { [weak self] _ in
            self?.onSwitchSymbolTapped?()
        }, for: .touchUpInside)

        addSubview(symbolLabel)
        addSubview(switchButton)
        symbolLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        switchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }
}
