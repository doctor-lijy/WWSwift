import UIKit
import SnapKit

final class AvailableBalanceView: UIView {
    private let availableLabel = UILabel()
    private let maxLongLabel = UILabel()
    private let maxShortLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        [availableLabel, maxLongLabel, maxShortLabel].forEach {
            $0.font = .systemFont(ofSize: 11)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 1
        }
        let stack = UIStackView(arrangedSubviews: [availableLabel, maxLongLabel, maxShortLabel])
        stack.axis = .vertical
        stack.spacing = 2
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 4, right: 12))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(available: String, maxLong: String, maxShort: String) {
        availableLabel.text = "可用 \(available)"
        maxLongLabel.text = "可开多 \(maxLong)"
        maxShortLabel.text = "可开空 \(maxShort)"
    }
}
