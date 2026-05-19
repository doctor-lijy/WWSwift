import UIKit
import SnapKit

final class OpenCloseTabView: UIView {
    var onModeChanged: ((OpenCloseMode) -> Void)?

    private let control = UISegmentedControl(items: OpenCloseMode.allCases.map(\.title))

    override init(frame: CGRect) {
        super.init(frame: frame)
        control.selectedSegmentIndex = 0
        control.addAction(UIAction { [weak self] _ in
            guard let self, let mode = OpenCloseMode(rawValue: self.control.selectedSegmentIndex) else { return }
            self.onModeChanged?(mode)
        }, for: .valueChanged)
        addSubview(control)
        control.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 4, right: 12))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ mode: OpenCloseMode) {
        control.selectedSegmentIndex = mode.rawValue
    }
}
