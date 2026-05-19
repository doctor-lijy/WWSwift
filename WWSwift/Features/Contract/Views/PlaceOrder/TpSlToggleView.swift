import UIKit
import SnapKit

final class TpSlToggleView: UIView {
    private let toggle = UISwitch()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.text = "止盈/止损"
        titleLabel.font = .systemFont(ofSize: 13)
        addSubview(titleLabel)
        addSubview(toggle)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        toggle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        snp.makeConstraints { make in
            make.height.equalTo(32)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
