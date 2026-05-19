import UIKit
import SnapKit

final class EnvironmentDebugViewController: UIViewController {
    private let environmentManager = EnvironmentManager()
    private let sessionStore = SessionStore()
    private let apiClient: APIClient

    private let envLabel = UILabel()
    private let urlLabel = UILabel()
    private let tokenField = UITextField()
    private let userIdField = UITextField()

    init() {
        self.apiClient = APIClient(environment: environmentManager, session: sessionStore)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "环境 Debug"
        view.backgroundColor = .systemBackground
        setupUI()
        refreshLabels()
    }

    private func setupUI() {
        envLabel.numberOfLines = 0
        urlLabel.numberOfLines = 0
        urlLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tokenField.placeholder = "Access Token"
        tokenField.borderStyle = .roundedRect
        userIdField.placeholder = "User ID"
        userIdField.borderStyle = .roundedRect

        let envStack = UIStackView()
        envStack.axis = .vertical
        envStack.spacing = 8
        AppEnvironment.allCases.forEach { env in
            let button = UIButton(type: .system)
            button.setTitle("切换: \(env.displayName)", for: .normal)
            button.addAction(UIAction { [weak self] _ in
                self?.environmentManager.setCurrent(env)
                self?.refreshLabels()
            }, for: .touchUpInside)
            envStack.addArrangedSubview(button)
        }

        let saveToken = UIButton(type: .system)
        saveToken.setTitle("保存 Token / UserId", for: .normal)
        saveToken.addAction(UIAction { [weak self] _ in
            self?.sessionStore.accessToken = self?.tokenField.text
            self?.sessionStore.userId = self?.userIdField.text
            self?.refreshLabels()
        }, for: .touchUpInside)

        let logout = UIButton(type: .system)
        logout.setTitle("触发退出登录", for: .normal)
        logout.addAction(UIAction { [weak self] _ in
            Task { await self?.triggerLogout() }
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            envLabel, urlLabel, tokenField, userIdField, saveToken, envStack, logout
        ])
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func refreshLabels() {
        envLabel.text = "当前环境: \(environmentManager.current.displayName)"
        urlLabel.text = "合约 API: \(environmentManager.contractAPIBaseURL.absoluteString)"
        tokenField.text = sessionStore.accessToken
        userIdField.text = sessionStore.userId
    }

    private func triggerLogout() async {
        do {
            let _: LogoutResponseDTO = try await apiClient.post(path: "v1/user/login/logout", body: [:])
            sessionStore.clear()
            refreshLabels()
            let alert = UIAlertController(title: "退出", message: "成功", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } catch {
            let alert = UIAlertController(title: "退出失败", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
