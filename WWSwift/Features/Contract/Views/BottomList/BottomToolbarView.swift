import UIKit
import SnapKit

final class BottomToolbarView: UIView {
    var onOnlyCurrentChanged: ((Bool) -> Void)?
    var onCloseAllTapped: (() -> Void)?

    private let onlyCurrentSwitch = UISwitch()
    private let onlyCurrentLabel = UILabel()
    private let closeAllButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        onlyCurrentLabel.text = "只看当前"
        onlyCurrentLabel.font = .systemFont(ofSize: 13)
        closeAllButton.setTitle("一键平仓", for: .normal)
        closeAllButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)

        onlyCurrentSwitch.addAction(UIAction { [weak self] _ in
            self?.onOnlyCurrentChanged?(self?.onlyCurrentSwitch.isOn ?? false)
        }, for: .valueChanged)
        closeAllButton.addAction(UIAction { [weak self] _ in
            self?.onCloseAllTapped?()
        }, for: .touchUpInside)

        let left = UIStackView(arrangedSubviews: [onlyCurrentSwitch, onlyCurrentLabel])
        left.axis = .horizontal
        left.spacing = 6
        left.alignment = .center

        let row = UIStackView(arrangedSubviews: [left, UIView(), closeAllButton])
        row.axis = .horizontal
        addSubview(row)
        row.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
            make.height.equalTo(36)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOnlyCurrent(_ enabled: Bool) {
        onlyCurrentSwitch.isOn = enabled
    }
}
