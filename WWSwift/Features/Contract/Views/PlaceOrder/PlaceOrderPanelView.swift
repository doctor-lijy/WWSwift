import UIKit
import SnapKit

final class PlaceOrderPanelView: UIView {
    var onPlaceOrder: ((PlaceOrderRequest) -> Void)?

    private var contractId: String = ""
    private var orderType: PlaceOrderType = .limit
    private var openCloseMode: OpenCloseMode = .open
    private var marginMode: ContractMarginMode = .isolated
    private var leverage: Int = 20

    private let fundingBar = FundingRateBarView()
    private let openCloseTab = OpenCloseTabView()
    private let orderTypeSelector = OrderTypeSelectorView()
    private let priceSizeInput = PriceSizeInputView()
    private let sizeSlider = SizeSliderView()
    private let balanceView = AvailableBalanceView()
    private let tpSlToggle = TpSlToggleView()
    private let costPreview = CostPreviewView()
    private let actionButtons = PlaceOrderButtonsView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        contractId: String,
        settings: ContractTradeSettings,
        fundingRate: String,
        fundingCountdown: String,
        available: String,
        maxLong: String,
        maxShort: String,
        cost: String,
        sizeText: String
    ) {
        self.contractId = contractId
        self.leverage = settings.leverage
        self.marginMode = settings.marginMode
        self.openCloseMode = settings.openCloseMode

        fundingBar.configure(rate: fundingRate, countdown: fundingCountdown)
        openCloseTab.setSelected(settings.openCloseMode)
        balanceView.configure(available: available, maxLong: maxLong, maxShort: maxShort)
        costPreview.configure(cost: cost)
        priceSizeInput.setSizeText(sizeText)
        actionButtons.setTitles(openMode: settings.openCloseMode)
    }

    func bindActions(
        onOpenCloseChanged: @escaping (OpenCloseMode) -> Void,
        onSizeChanged: @escaping (String) -> Void,
        onSizePercent: @escaping (Float) -> Void
    ) {
        openCloseTab.onModeChanged = { [weak self] mode in
            self?.openCloseMode = mode
            self?.actionButtons.setTitles(openMode: mode)
            onOpenCloseChanged(mode)
        }
        orderTypeSelector.onOrderTypeChanged = { [weak self] type in
            self?.orderType = type
            self?.priceSizeInput.setLimitEnabled(type == .limit)
        }
        priceSizeInput.onSizeChanged = onSizeChanged
        sizeSlider.onPercentChanged = onSizePercent
    }

    private func setup() {
        orderTypeSelector.onOrderTypeChanged = { [weak self] type in
            self?.orderType = type
            self?.priceSizeInput.setLimitEnabled(type == .limit)
        }
        actionButtons.onBuyLong = { [weak self] in self?.submit(side: .buy) }
        actionButtons.onSellShort = { [weak self] in self?.submit(side: .sell) }

        let stack = UIStackView(arrangedSubviews: [
            fundingBar,
            openCloseTab,
            orderTypeSelector,
            priceSizeInput,
            sizeSlider,
            balanceView,
            tpSlToggle,
            costPreview,
            actionButtons
        ])
        stack.axis = .vertical
        stack.spacing = 4
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        priceSizeInput.setLimitEnabled(true)
    }

    private func submit(side: PlaceOrderSide) {
        let request = PlaceOrderRequest(
            contractId: contractId,
            orderSide: side,
            orderType: orderType,
            size: priceSizeInput.sizeField.text ?? "",
            price: priceSizeInput.priceField.text,
            marginMode: marginMode.placeMarginMode,
            leverage: leverage
        )
        onPlaceOrder?(request)
    }
}
