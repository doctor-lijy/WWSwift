import UIKit
import SnapKit

final class CostPreviewView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 4, right: 12))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(cost: String) {
        label.text = "预估成本 \(cost)"
    }
}
