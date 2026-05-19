import UIKit
import SnapKit

final class ContractViewController: UIViewController {
    private let viewModel: ContractViewModel
    private lazy var coordinator = ContractCoordinator(viewController: self, viewModel: viewModel)

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let headerView = ContractHeaderView()
    private let leverageBar = LeverageBarView()
    private let placeOrderPanel = PlaceOrderPanelView()
    private let orderBookView = ContractOrderBookView()
    private let bottomSegment = BottomSegmentedView()
    private let bottomToolbar = BottomToolbarView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStateView = EmptyStateView()
    private let errorLabel = UILabel()

    init(viewModel: ContractViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "合约"
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()
        Task { await viewModel.loadInitialData() }
    }

    private func setupUI() {
        errorLabel.textColor = .systemRed
        errorLabel.font = .preferredFont(forTextStyle: .footnote)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ContractPositionCell.self, forCellReuseIdentifier: ContractPositionCell.reuseId)
        tableView.register(ContractOrderCell.self, forCellReuseIdentifier: ContractOrderCell.reuseId)
        tableView.rowHeight = 56

        headerView.onSwitchSymbolTapped = { [weak self] in
            guard let self else { return }
            self.coordinator.presentSymbolPicker(from: self)
        }
        leverageBar.onAdjustTapped = { [weak self] in
            self?.presentLeveragePlaceholder()
        }
        bottomSegment.onSegmentChanged = { [weak self] segment in
            Task { await self?.viewModel.setSegment(segment) }
        }
        bottomToolbar.onOnlyCurrentChanged = { [weak self] enabled in
            Task { await self?.viewModel.setOnlyCurrentSymbol(enabled) }
        }
        bottomToolbar.onCloseAllTapped = { [weak self] in
            self?.presentCloseAllPlaceholder()
        }
        placeOrderPanel.onPlaceOrder = { [weak self] request in
            guard let self else { return }
            self.coordinator.handlePlaceOrder(from: self, request: request)
        }
        placeOrderPanel.bindActions(
            onOpenCloseChanged: { [weak self] mode in
                self?.viewModel.setOpenCloseMode(mode)
            },
            onSizeChanged: { [weak self] text in
                self?.viewModel.setSizeInput(text)
            },
            onSizePercent: { [weak self] percent in
                self?.viewModel.updateSizePercent(percent)
            }
        )
        emptyStateView.onDepositTapped = { [weak self] in
            self?.showPlaceholderAlert("充值入口为 M2 占位")
        }
        emptyStateView.onTransferTapped = { [weak self] in
            self?.showPlaceholderAlert("划转入口为 M2 占位")
        }

        let leftColumn = UIStackView(arrangedSubviews: [leverageBar, placeOrderPanel])
        leftColumn.axis = .vertical
        leftColumn.spacing = 0

        let topRow = UIStackView(arrangedSubviews: [leftColumn, orderBookView])
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .top
        topRow.distribution = .fill

        orderBookView.snp.makeConstraints { make in
            make.width.equalTo(topRow.snp.width).multipliedBy(0.38)
        }

        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.addArrangedSubview(headerView)
        contentStack.addArrangedSubview(topRow)
        contentStack.addArrangedSubview(bottomSegment)
        contentStack.addArrangedSubview(bottomToolbar)
        contentStack.addArrangedSubview(errorLabel)
        contentStack.addArrangedSubview(tableView)

        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        tableView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(220)
        }
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.render()
        }
        viewModel.onTickUpdate = { [weak self] in
            self?.renderTicker()
        }
    }

    private func render() {
        let contractId = viewModel.selectedSymbol?.contractId ?? ""
        headerView.configure(symbolName: viewModel.selectedSymbol?.symbolName ?? "—")
        leverageBar.configure(
            leverage: viewModel.tradeSettings.leverage,
            marginMode: viewModel.tradeSettings.marginMode
        )
        placeOrderPanel.configure(
            contractId: contractId,
            settings: viewModel.tradeSettings,
            fundingRate: viewModel.fundingRateText,
            fundingCountdown: viewModel.fundingCountdownText,
            available: viewModel.availableBalanceText,
            maxLong: viewModel.maxOpenLongText,
            maxShort: viewModel.maxOpenShortText,
            cost: viewModel.costPreviewText,
            sizeText: viewModel.sizeInputText
        )
        orderBookView.update(snapshot: viewModel.orderBook)
        bottomSegment.setSelected(viewModel.segment)
        bottomToolbar.setOnlyCurrent(viewModel.onlyCurrentSymbol)

        if let message = viewModel.errorMessage, !message.isEmpty {
            errorLabel.text = message
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }

        renderTicker()
        updateEmptyState()
        tableView.reloadData()
    }

    private func renderTicker() {
        headerView.updateTicker(
            lastPrice: viewModel.currentTick?.lastPrice,
            priceChangePercent: viewModel.currentTick?.priceChangePercent
        )
        headerView.updateSocketStatus(viewModel.socketConnected)
        if let price = viewModel.currentTick?.lastPrice {
            orderBookView.update(snapshot: .mock(lastPrice: price))
        }
    }

    private func updateEmptyState() {
        if viewModel.isBottomListEmpty {
            let message = viewModel.segment == .positions ? "暂无持仓" : "暂无当前委托"
            emptyStateView.setMessage(message)
            tableView.backgroundView = emptyStateView
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }

    private func presentLeveragePlaceholder() {
        showPlaceholderAlert("杠杆调整将在 M3 对接 API")
    }

    private func presentCloseAllPlaceholder() {
        showPlaceholderAlert("一键平仓将在 M3 对接真实持仓")
    }

    private func showPlaceholderAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

extension ContractViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.bottomRowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.segment {
        case .positions:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ContractPositionCell.reuseId,
                for: indexPath
            ) as! ContractPositionCell
            if let position = viewModel.position(at: indexPath.row) {
                cell.configure(position)
            }
            return cell
        case .activeOrders:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ContractOrderCell.reuseId,
                for: indexPath
            ) as! ContractOrderCell
            if let order = viewModel.order(at: indexPath.row) {
                cell.configure(order)
            }
            return cell
        }
    }
}

extension ContractViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        coordinator.handleRowSelection(at: indexPath.row, from: self)
    }
}
