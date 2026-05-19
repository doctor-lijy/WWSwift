import Foundation

struct ContractPosition: Equatable {
    let positionId: String
    let contractId: String
    let side: String
    let size: String
    let unrealizedPnL: String

    var displayTitle: String {
        "\(side) \(size) · PnL \(unrealizedPnL)"
    }
}
