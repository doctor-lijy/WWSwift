import Foundation

enum ContractMarginMode: String, CaseIterable {
    case isolated
    case cross

    var displayTitle: String {
        switch self {
        case .isolated: return "逐仓"
        case .cross: return "全仓"
        }
    }

    var placeMarginMode: PlaceMarginMode {
        switch self {
        case .isolated: return .isolated
        case .cross: return .shared
        }
    }
}

enum OpenCloseMode: Int, CaseIterable {
    case open = 0
    case close = 1

    var title: String {
        switch self {
        case .open: return "开仓"
        case .close: return "平仓"
        }
    }
}

struct ContractTradeSettings: Equatable {
    var leverage: Int = 20
    var marginMode: ContractMarginMode = .isolated
    var openCloseMode: OpenCloseMode = .open
}
