import UIKit
import SnapKit

final class ContractSegmentView: UIView {
    var onSegmentChanged: ((ContractListSegment) -> Void)?

    private let segmentedControl: UISegmentedControl

    override init(frame: CGRect) {
        segmentedControl = UISegmentedControl(items: ContractListSegment.allCases.map(\.title))
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ segment: ContractListSegment) {
        segmentedControl.selectedSegmentIndex = segment.rawValue
    }

    private func setup() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let index = self.segmentedControl.selectedSegmentIndex
            guard let segment = ContractListSegment(rawValue: index) else { return }
            self.onSegmentChanged?(segment)
        }, for: .valueChanged)

        addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }
}
