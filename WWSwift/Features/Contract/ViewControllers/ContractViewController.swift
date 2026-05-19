import UIKit
import SnapKit

final class ContractViewController: UIViewController {
    private let viewModel: ContractViewModel
    private lazy var coordinator = ContractCoordinator(viewController: self, viewModel: viewModel)

    private let headerView = ContractHeaderView()
    private let segmentView = ContractSegmentView()
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        headerView.onSwitchSymbolTapped = { [weak self] in
            guard let self else { return }
            self.coordinator.presentSymbolPicker(from: self)
        }
        segmentView.onSegmentChanged = { [weak self] segment in
            Task { await self?.viewModel.setSegment(segment) }
        }

        view.addSubview(headerView)
        view.addSubview(segmentView)
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
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom).offset(4)
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
    }

    private func render() {
        headerView.configure(symbolName: viewModel.selectedSymbol?.symbolName ?? "—")
        segmentView.setSelected(viewModel.segment)
        if let message = viewModel.errorMessage, !message.isEmpty {
            errorLabel.text = message
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
        tableView.reloadData()
    }
}

extension ContractViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.tableRows[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}
