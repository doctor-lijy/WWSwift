import UIKit
import SnapKit

final class FundingRateBarView: UIView {
    private let rateLabel = UILabel()
    private let countdownLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        rateLabel.font = .systemFont(ofSize: 12)
        countdownLabel.font = .systemFont(ofSize: 12)
        countdownLabel.textColor = .secondaryLabel
        countdownLabel.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [rateLabel, countdownLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 4, right: 12))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(rate: String, countdown: String) {
        rateLabel.text = "资金费率 \(rate)"
        countdownLabel.text = countdown
    }
}
