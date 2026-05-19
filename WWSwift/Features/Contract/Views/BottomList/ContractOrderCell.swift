import UIKit

final class ContractOrderCell: UITableViewCell {
    static let reuseId = "ContractOrderCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ order: ContractOrder) {
        textLabel?.text = order.side
        detailTextLabel?.text = "\(order.size) @ \(order.price)"
    }
}
