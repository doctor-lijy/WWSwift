import UIKit
import SnapKit

final class BottomSegmentedView: UIView {
    var onSegmentChanged: ((ContractListSegment) -> Void)?

    private let control = UISegmentedControl(items: ContractListSegment.allCases.map(\.title))

    override init(frame: CGRect) {
        super.init(frame: frame)
        control.selectedSegmentIndex = 0
        control.addAction(UIAction { [weak self] _ in
            guard let segment = ContractListSegment(rawValue: self?.control.selectedSegmentIndex ?? 0) else { return }
            self?.onSegmentChanged?(segment)
        }, for: .valueChanged)
        addSubview(control)
        control.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 4, right: 16))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ segment: ContractListSegment) {
        control.selectedSegmentIndex = segment.rawValue
    }
}
