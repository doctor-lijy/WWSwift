import Foundation

enum PlaceOrderType: String, CaseIterable {
    case limit = "LIMIT"
    case market = "MARKET"
}

enum PlaceOrderSide: String, CaseIterable {
    case buy = "BUY"
    case sell = "SELL"
}

enum PlaceMarginMode: String, CaseIterable {
    case shared = "SHARED"
    case isolated = "ISOLATED"
}

enum PlaceOrderValidationError: Error, Equatable {
    case emptyContractId
    case invalidSize
    case missingLimitPrice
    case invalidLimitPrice
    case invalidLeverage

    var localizedMessage: String {
        switch self {
        case .emptyContractId: return "合约 ID 不能为空"
        case .invalidSize: return "数量必须大于 0"
        case .missingLimitPrice: return "限价单需要填写价格"
        case .invalidLimitPrice: return "限价必须大于 0"
        case .invalidLeverage: return "杠杆需在 1–125 之间"
        }
    }
}

struct PlaceOrderRequest: Equatable {
    let contractId: String
    let orderSide: PlaceOrderSide
    let orderType: PlaceOrderType
    let size: String
    let price: String?
    let marginMode: PlaceMarginMode
    let leverage: Int

    func validate() -> Result<Void, PlaceOrderValidationError> {
        guard !contractId.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyContractId)
        }
        guard let sizeValue = Double(size), sizeValue > 0 else {
            return .failure(.invalidSize)
        }
        switch orderType {
        case .limit:
            guard let price, !price.isEmpty else {
                return .failure(.missingLimitPrice)
            }
            guard let priceValue = Double(price), priceValue > 0 else {
                return .failure(.invalidLimitPrice)
            }
        case .market:
            break
        }
        guard (1...125).contains(leverage) else {
            return .failure(.invalidLeverage)
        }
        return .success(())
    }

    func apiParameters() -> [String: Any] {
        var params: [String: Any] = [
            "contractId": contractId,
            "marginMode": marginMode.rawValue,
            "separatedMode": "COMBINED",
            "positionSide": orderSide == .buy ? "LONG" : "SHORT",
            "orderSide": orderSide.rawValue,
            "size": size,
            "type": orderType.rawValue,
            "timeInForce": "GOOD_TIL_CANCEL",
            "reduceOnly": false
        ]
        if orderType == .limit, let price {
            params["price"] = price
        } else {
            params["price"] = ""
        }
        return params
    }

    var summaryText: String {
        let priceText = orderType == .limit ? (price ?? "—") : "市价"
        return "\(orderSide.rawValue) \(size) @ \(priceText) · \(marginMode.rawValue) · \(leverage)x"
    }
}
