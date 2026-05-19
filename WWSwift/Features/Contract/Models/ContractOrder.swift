import Foundation

struct ContractOrder: Equatable {
    let orderId: String
    let contractId: String
    let side: String
    let size: String
    let price: String

    var displayTitle: String {
        "\(side) \(size) @ \(price)"
    }
}
