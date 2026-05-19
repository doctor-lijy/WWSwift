import UIKit
import SnapKit

final class PlaceOrderPanelView: UIView {
    var onPlaceOrder: ((PlaceOrderRequest) -> Void)?

    private var contractId: String = ""

    private let orderTypeControl = UISegmentedControl(items: ["限价", "市价"])
    private let sideControl = UISegmentedControl(items: ["买入", "卖出"])
    private let marginControl = UISegmentedControl(items: ["全仓", "逐仓"])
    private let sizeField = UITextField()
    private let priceField = UITextField()
    private let leverageField = UITextField()
    private let placeOrderButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(contractId: String) {
        self.contractId = contractId
    }

    private func setup() {
        orderTypeControl.selectedSegmentIndex = 0
        sideControl.selectedSegmentIndex = 0
        marginControl.selectedSegmentIndex = 0

        sizeField.placeholder = "数量"
        sizeField.borderStyle = .roundedRect
        sizeField.keyboardType = .decimalPad

        priceField.placeholder = "价格（限价）"
        priceField.borderStyle = .roundedRect
        priceField.keyboardType = .decimalPad

        leverageField.placeholder = "杠杆 1-125"
        leverageField.borderStyle = .roundedRect
        leverageField.keyboardType = .numberPad
        leverageField.text = "20"

        placeOrderButton.setTitle("下单", for: .normal)
        placeOrderButton.backgroundColor = .systemBlue
        placeOrderButton.setTitleColor(.white, for: .normal)
        placeOrderButton.layer.cornerRadius = 8
        placeOrderButton.addAction(UIAction { [weak self] _ in
            self?.submitOrder()
        }, for: .touchUpInside)

        orderTypeControl.addAction(UIAction { [weak self] _ in
            self?.updatePriceFieldState()
        }, for: .valueChanged)

        let row1 = UIStackView(arrangedSubviews: [orderTypeControl, sideControl])
        row1.axis = .horizontal
        row1.spacing = 8
        row1.distribution = .fillEqually

        let row2 = UIStackView(arrangedSubviews: [sizeField, priceField])
        row2.axis = .horizontal
        row2.spacing = 8
        row2.distribution = .fillEqually

        let row3 = UIStackView(arrangedSubviews: [marginControl, leverageField])
        row3.axis = .horizontal
        row3.spacing = 8
        row3.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [row1, row2, row3, placeOrderButton])
        stack.axis = .vertical
        stack.spacing = 8

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        placeOrderButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        updatePriceFieldState()
    }

    private func updatePriceFieldState() {
        let isLimit = orderTypeControl.selectedSegmentIndex == 0
        priceField.isEnabled = isLimit
        priceField.alpha = isLimit ? 1 : 0.4
        if !isLimit {
            priceField.text = nil
        }
    }

    private func submitOrder() {
        let orderType: PlaceOrderType = orderTypeControl.selectedSegmentIndex == 0 ? .limit : .market
        let side: PlaceOrderSide = sideControl.selectedSegmentIndex == 0 ? .buy : .sell
        let margin: PlaceMarginMode = marginControl.selectedSegmentIndex == 0 ? .shared : .isolated
        let leverage = Int(leverageField.text ?? "") ?? 0
        let request = PlaceOrderRequest(
            contractId: contractId,
            orderSide: side,
            orderType: orderType,
            size: sizeField.text ?? "",
            price: priceField.text,
            marginMode: margin,
            leverage: leverage
        )
        onPlaceOrder?(request)
    }
}
