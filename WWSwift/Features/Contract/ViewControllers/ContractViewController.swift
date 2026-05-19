import UIKit
import SnapKit

final class ContractViewController: UIViewController {
    private let viewModel: ContractViewModel
    private lazy var coordinator = ContractCoordinator(viewController: self, viewModel: viewModel)

    private let headerView = ContractHeaderView()
    private let segmentView = ContractSegmentView()
    private let placeOrderPanel = PlaceOrderPanelView()
    private let tableView = UITableView(frame: .zero, style: .plain)
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        headerView.onSwitchSymbolTapped = { [weak self] in
            guard let self else { return }
            self.coordinator.presentSymbolPicker(from: self)
        }
        segmentView.onSegmentChanged = { [weak self] segment in
            Task { await self?.viewModel.setSegment(segment) }
        }
        placeOrderPanel.onPlaceOrder = { [weak self] request in
            guard let self else { return }
            self.coordinator.handlePlaceOrder(from: self, request: request)
        }

        view.addSubview(headerView)
        view.addSubview(segmentView)
        view.addSubview(placeOrderPanel)
        view.addSubview(errorLabel)
        view.addSubview(tableView)

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        placeOrderPanel.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(placeOrderPanel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
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
        placeOrderPanel.configure(contractId: contractId)
        segmentView.setSelected(viewModel.segment)
        if let message = viewModel.errorMessage, !message.isEmpty {
            errorLabel.text = message
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        renderTicker()
        tableView.reloadData()
    }

    private func renderTicker() {
        headerView.updateTicker(
            lastPrice: viewModel.currentTick?.lastPrice,
            priceChangePercent: viewModel.currentTick?.priceChangePercent
        )
        headerView.updateSocketStatus(viewModel.socketConnected)
    }
}

extension ContractViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.tableRows[indexPath.row]
        let isPlaceholder = viewModel.tableRows[indexPath.row].hasPrefix("暂无") || viewModel.tableRows[indexPath.row].hasPrefix("加载失败")
        cell.selectionStyle = isPlaceholder ? .none : .default
        cell.accessoryType = isPlaceholder ? .none : .disclosureIndicator
        return cell
    }
}

extension ContractViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = viewModel.tableRows[indexPath.row]
        guard !row.hasPrefix("暂无"), !row.hasPrefix("加载失败") else { return }
        coordinator.handleRowSelection(at: indexPath.row, from: self)
    }
}
