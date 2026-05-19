import UIKit
import SnapKit

final class OrderTypeSelectorView: UIView {
    var onOrderTypeChanged: ((PlaceOrderType) -> Void)?

    private let control = UISegmentedControl(items: ["限价", "市价"])

    override init(frame: CGRect) {
        super.init(frame: frame)
        control.selectedSegmentIndex = 0
        control.addAction(UIAction { [weak self] _ in
            let type: PlaceOrderType = self?.control.selectedSegmentIndex == 0 ? .limit : .market
            self?.onOrderTypeChanged?(type)
        }, for: .valueChanged)
        addSubview(control)
        control.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 4, right: 12))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
