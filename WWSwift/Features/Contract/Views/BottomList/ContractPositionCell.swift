import UIKit

final class ContractPositionCell: UITableViewCell {
    static let reuseId = "ContractPositionCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ position: ContractPosition) {
        textLabel?.text = position.side
        detailTextLabel?.text = "数量 \(position.size) · 未实现盈亏 \(position.unrealizedPnL)"
    }
}
