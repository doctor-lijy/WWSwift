import UIKit
import SnapKit

final class EnvironmentDebugViewController: UIViewController {
    private let environmentManager = EnvironmentManager()
    private let sessionStore = SessionStore()
    private lazy var apiClient = APIClient(environment: environmentManager, session: sessionStore)
    private lazy var logoutCoordinator = LogoutCoordinator(
        presentingViewController: self,
        logoutService: LogoutService(apiClient: apiClient, session: sessionStore)
    )

    private let envLabel = UILabel()
    private let urlLabel = UILabel()
    private let tokenField = UITextField()
    private let userTokenField = UITextField()
    private let rTokenField = UITextField()
    private let userIdField = UITextField()

    init() {
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
        tokenField.placeholder = "Access Token (u-token)"
        tokenField.borderStyle = .roundedRect
        userTokenField.placeholder = "User Token (HTTP header `token`)"
        userTokenField.borderStyle = .roundedRect
        rTokenField.placeholder = "R Token (Socket X-TOKEN)"
        rTokenField.borderStyle = .roundedRect
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
            self?.sessionStore.userToken = self?.userTokenField.text
            self?.sessionStore.rToken = self?.rTokenField.text
            self?.sessionStore.userId = self?.userIdField.text
            self?.refreshLabels()
        }, for: .touchUpInside)

        let logout = UIButton(type: .system)
        logout.setTitle("触发退出登录", for: .normal)
        logout.addAction(UIAction { [weak self] _ in
            Task { await self?.triggerLogout() }
        }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            envLabel, urlLabel,
            tokenField, userTokenField, rTokenField, userIdField,
            saveToken, envStack, logout
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
        let sampleURL = environmentManager.url(for: "api/v1/public/meta/getMetaDataNew")
        envLabel.text = "当前环境: \(environmentManager.current.displayName) · isLogin=\(sessionStore.isLoggedIn)"
        urlLabel.text = "合约 API: \(sampleURL.absoluteString)"
        tokenField.text = sessionStore.accessToken
        userTokenField.text = sessionStore.userToken
        rTokenField.text = sessionStore.rToken
        userIdField.text = sessionStore.userId
    }

    private func triggerLogout() async {
        await logoutCoordinator.performLogout()
        refreshLabels()
    }
}
