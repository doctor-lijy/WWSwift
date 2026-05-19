# WWSwift 独立工程 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在独立仓库中用 UIKit + SnapKit 实现可运行 Demo：环境/Mock 切换、退出登录、合约交易 A+B+C（排除跟单），与 weexios 行为可对照。

**Architecture:** 单 Target 分层（App / Core / Features）；View → ViewModel → Coordinator → Service → APIClient；`EnvironmentManager` 在 mock 与 test/stg/prod 间切换；网络层 Swift 自研，不依赖 PHNet。

**Tech Stack:** iOS 14+、Swift 5、UIKit、SnapKit、CocoaPods、XcodeGen（工程生成）、URLSession、单元测试（XCTest）

**Spec:** [`docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md`](../specs/2026-05-19-wwswift-standalone-design.md)  
**本机路径:** `/Users/lijingyi/Desktop/WW/AITest/WWSwift`  
**weexios 只读对照:** `/Users/lijingyi/Desktop/WW/weexios/WeexExchange`

**建议执行环境:** 使用 `using-git-worktrees` 在独立 worktree 中实施，避免污染当前 main 工作区。

---

## 文件结构总览（P0 结束时目标）

| 路径 | 职责 |
|------|------|
| `project.yml` | XcodeGen 工程定义（App + Unit Tests） |
| `Podfile` / `WWSwift.xcworkspace` | SnapKit、SDWebImage |
| `WWSwift/App/` | AppDelegate、Tab、Debug 页 |
| `WWSwift/Core/Network/` | Environment、APIClient、Mock、签名 |
| `WWSwift/Core/Session/` | SessionStore |
| `WWSwift/Core/Storage/` | UserDefaults 封装 |
| `WWSwift/Features/Logout/` | P1 退出链路 |
| `WWSwift/Features/Contract/` | P2–P4 合约 |
| `WWSwiftTests/` | ViewModel / Service 单元测试 |
| `docs/api/endpoints.md` | 从 `ApiConst.h` 摘录 |
| `docs/reference/weexios-mapping.md` | P5 对照表 |
| `.cursor/rules/*.mdc` | 三条规则 |
| `.cursor/agents/*.md` | 四个 agent |
| `.codex/skills/wwswift-*/SKILL.md` | 三个 skill |
| `SourceCode/`、`WWSwift.podspec` | **删除**（Pod 库脚手架，由 App 工程替代） |

---

## Phase P0 — 工程骨架、网络 Core、Debug、Agents/Rules/Skills

### Task 1: 添加 XcodeGen 与 Podfile

**Files:**
- Create: `project.yml`
- Create: `Podfile`
- Modify: `.gitignore`

- [ ] **Step 1: 创建 `project.yml`**

```yaml
name: WWSwift
options:
  bundleIdPrefix: com.weex.wwswift
  deploymentTarget:
    iOS: "14.0"
  createIntermediateGroups: true
settings:
  base:
    SWIFT_VERSION: "5.0"
    IPHONEOS_DEPLOYMENT_TARGET: "14.0"
targets:
  WWSwift:
    type: application
    platform: iOS
    sources:
      - path: WWSwift
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.weex.wwswift.app
      INFOPLIST_KEY_UILaunchStoryboardName: LaunchScreen
      GENERATE_INFOPLIST_FILE: YES
      INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents: YES
      INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
    scheme:
      testTargets:
        - WWSwiftTests
  WWSwiftTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: WWSwiftTests
    dependencies:
      - target: WWSwift
    settings:
      GENERATE_INFOPLIST_FILE: YES
```

- [ ] **Step 2: 创建 `Podfile`**

```ruby
platform :ios, '14.0'
use_frameworks!

target 'WWSwift' do
  pod 'SnapKit', '~> 5.7'
  pod 'SDWebImage', '~> 5.19'
end

target 'WWSwiftTests' do
  inherit! :search_paths
end
```

- [ ] **Step 3: 更新 `.gitignore`**

在文件末尾追加：

```
# XcodeGen
*.xcodeproj
!project.yml

# Keep workspace from CocoaPods
!WWSwift.xcworkspace
```

- [ ] **Step 4: 安装工具并生成工程**

Run:

```bash
cd /Users/lijingyi/Desktop/WW/AITest/WWSwift
brew list xcodegen >/dev/null 2>&1 || brew install xcodegen
xcodegen generate
pod install
```

Expected: 生成 `WWSwift.xcodeproj`、`WWSwift.xcworkspace`，`Pods/` 已安装。

- [ ] **Step 5: Commit**

```bash
git add project.yml Podfile .gitignore
git commit -m "chore: add XcodeGen project and CocoaPods Podfile"
```

---

### Task 2: App 入口与 Tab 骨架

**Files:**
- Create: `WWSwift/App/AppDelegate.swift`
- Create: `WWSwift/App/SceneDelegate.swift`
- Create: `WWSwift/App/MainTabBarController.swift`
- Create: `WWSwift/Resources/LaunchScreen.storyboard`（或由 XcodeGen 自动生成后补最小 storyboard）

- [ ] **Step 1: 编写 `AppDelegate.swift`**

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
```

- [ ] **Step 2: 编写 `SceneDelegate.swift`**

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
```

在 `project.yml` 的 `WWSwift` target `settings` 增加：

```yaml
INFOPLIST_KEY_UIApplicationSceneManifest_Generation: YES
INFOPLIST_KEY_UILaunchStoryboardName: LaunchScreen
```

并添加 `WWSwift/Resources/Info.plist` 片段（若 GENERATE_INFOPLIST 不足）：

```xml
<key>UIApplicationSceneManifest</key>
<dict>
  <key>UIApplicationSupportsMultipleScenes</key>
  <false/>
  <key>UISceneConfigurations</key>
  <dict>
    <key>UIWindowSceneSessionRoleApplication</key>
    <array>
      <dict>
        <key>UISceneConfigurationName</key>
        <string>Default Configuration</string>
        <key>UISceneDelegateClassName</key>
        <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
      </dict>
    </array>
  </dict>
</dict>
```

- [ ] **Step 3: 编写 `MainTabBarController.swift`**

```swift
import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let contract = UINavigationController(rootViewController: ContractPlaceholderViewController())
        contract.tabBarItem = UITabBarItem(title: "合约", image: nil, tag: 0)

        #if DEBUG
        let debug = UINavigationController(rootViewController: EnvironmentDebugViewController())
        debug.tabBarItem = UITabBarItem(title: "Debug", image: nil, tag: 1)
        viewControllers = [contract, debug]
        #else
        viewControllers = [contract]
        #endif
    }
}

/// P2 替换为真实 ContractViewController
final class ContractPlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "合约"
        let label = UILabel()
        label.text = "合约页 — P2 落地"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
```

- [ ] **Step 4: 编译验证**

Run:

```bash
cd /Users/lijingyi/Desktop/WW/AITest/WWSwift
xcodegen generate
xcodebuild -workspace WWSwift.xcworkspace -scheme WWSwift -destination 'platform=iOS Simulator,name=iPhone 16' -quiet build
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Commit**

```bash
git add WWSwift/App/
git commit -m "feat: add App entry and main tab shell"
```

---

### Task 3: EnvironmentManager + SessionStore（TDD）

**Files:**
- Create: `WWSwift/Core/Network/AppEnvironment.swift`
- Create: `WWSwift/Core/Network/EnvironmentManager.swift`
- Create: `WWSwift/Core/Session/SessionStore.swift`
- Create: `WWSwift/Core/Storage/UserDefaultsStorage.swift`
- Create: `WWSwiftTests/Core/EnvironmentManagerTests.swift`
- Create: `WWSwiftTests/Core/SessionStoreTests.swift`

- [ ] **Step 1: 写失败测试 `EnvironmentManagerTests`**

```swift
import XCTest
@testable import WWSwift

final class EnvironmentManagerTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "WWSwiftTests.EnvironmentManager")!
        defaults.removePersistentDomain(forName: "WWSwiftTests.EnvironmentManager")
    }

    func test_defaultEnvironment_isMock() {
        let manager = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        XCTAssertEqual(manager.current, .mock)
    }

    func test_switchEnvironment_persists() {
        let manager = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        manager.setCurrent(.test)
        let reloaded = EnvironmentManager(storage: UserDefaultsStorage(defaults: defaults))
        XCTAssertEqual(reloaded.current, .test)
        XCTAssertTrue(reloaded.contractAPIBaseURL.absoluteString.hasPrefix("https://"))
    }
}
```

- [ ] **Step 2: 运行测试确认失败**

Run:

```bash
xcodebuild -workspace WWSwift.xcworkspace -scheme WWSwift -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:WWSwiftTests/EnvironmentManagerTests test 2>&1 | tail -20
```

Expected: FAIL — `EnvironmentManager` not found

- [ ] **Step 3: 实现 `AppEnvironment.swift`**

```swift
import Foundation

enum AppEnvironment: String, CaseIterable, Codable {
    case mock
    case test
    case stg
    case prod

    var displayName: String {
        switch self {
        case .mock: return "Mock"
        case .test: return "Test (T3)"
        case .stg: return "STG"
        case .prod: return "Prod"
        }
    }
}
```

- [ ] **Step 4: 实现 `UserDefaultsStorage.swift`**

```swift
import Foundation

protocol KeyValueStorage {
    func string(forKey key: String) -> String?
    func set(_ value: String?, forKey key: String)
    func integer(forKey key: String) -> Int
    func set(_ value: Int, forKey key: String)
}

struct UserDefaultsStorage: KeyValueStorage {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func set(_ value: String?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func integer(forKey key: String) -> Int {
        defaults.integer(forKey: key)
    }

    func set(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
```

- [ ] **Step 5: 实现 `EnvironmentManager.swift`**

对照 weexios `currentEnv` + `DomainManager.getRealUrl_New:`。P0 使用**可配置常量**（后续从 `pullNetConfigFile` 对齐时再改）：

```swift
import Foundation

final class EnvironmentManager {
    static let currentEnvKey = "currentEnv"

    private let storage: KeyValueStorage

    init(storage: KeyValueStorage = UserDefaultsStorage()) {
        self.storage = storage
        if storage.string(forKey: Self.currentEnvKey) == nil {
            setCurrent(.mock)
        }
    }

    var current: AppEnvironment {
        let raw = storage.string(forKey: Self.currentEnvKey) ?? AppEnvironment.mock.rawValue
        return AppEnvironment(rawValue: raw) ?? .mock
    }

    func setCurrent(_ env: AppEnvironment) {
        storage.set(env.rawValue, forKey: Self.currentEnvKey)
    }

    /// 新合约 API 域名 — 对齐 DomainManager.getRealUrl_New
    var contractAPIBaseURL: URL {
        switch current {
        case .mock:
            return URL(string: "https://mock.wwswift.local")!
        case .test:
            return URL(string: "https://http-gateway1.janapw.com")!
        case .stg:
            return URL(string: "https://http-gateway1.weex.com")!
        case .prod:
            return URL(string: "https://http-gateway1.weex.com")!
        }
    }

    func url(for path: String) -> URL {
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return contractAPIBaseURL.appendingPathComponent(trimmed)
    }
}
```

> **注意:** test/stg/prod 域名须在对照 weexios 真机切换环境时用 Debug 页打印 URL 校验；写入 `docs/api/endpoints.md` 的「环境表」。

- [ ] **Step 6: 实现 `SessionStore.swift` + 测试**

```swift
import Foundation

final class SessionStore {
    static let tokenKey = "SP_KEY_TOKEN"
    static let userIdKey = "SP_KEY_USER_ID"

    private let storage: KeyValueStorage

    init(storage: KeyValueStorage = UserDefaultsStorage()) {
        self.storage = storage
    }

    var accessToken: String? {
        get { storage.string(forKey: Self.tokenKey) }
        set { storage.set(newValue, forKey: Self.tokenKey) }
    }

    var userId: String? {
        get { storage.string(forKey: Self.userIdKey) }
        set { storage.set(newValue, forKey: Self.userIdKey) }
    }

    var isLoggedIn: Bool {
        guard let token = accessToken else { return false }
        return !token.isEmpty
    }

    func clear() {
        accessToken = nil
        userId = nil
    }
}
```

`SessionStoreTests.swift`:

```swift
import XCTest
@testable import WWSwift

final class SessionStoreTests: XCTestCase {
    func test_clear_removesTokenAndUserId() {
        let defaults = UserDefaults(suiteName: "WWSwiftTests.SessionStore")!
        defaults.removePersistentDomain(forName: "WWSwiftTests.SessionStore")
        let storage = UserDefaultsStorage(defaults: defaults)
        let store = SessionStore(storage: storage)
        store.accessToken = "abc"
        store.userId = "u1"
        store.clear()
        XCTAssertFalse(store.isLoggedIn)
        XCTAssertNil(store.userId)
    }
}
```

- [ ] **Step 7: 运行测试**

Run:

```bash
xcodebuild -workspace WWSwift.xcworkspace -scheme WWSwift -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:WWSwiftTests test
```

Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add WWSwift/Core/ WWSwiftTests/
git commit -m "feat: add EnvironmentManager and SessionStore with unit tests"
```

---

### Task 4: APIError、APIClient、MockProvider

**Files:**
- Create: `WWSwift/Core/Network/APIError.swift`
- Create: `WWSwift/Core/Network/APIClient.swift`
- Create: `WWSwift/Core/Network/MockProvider.swift`
- Create: `WWSwift/Core/Network/RequestSigning.swift`
- Create: `WWSwiftTests/Core/APIClientTests.swift`
- Create: `WWSwift/Resources/Mocks/logout_success.json`

- [ ] **Step 1: 写失败测试 — mock 退出成功**

```swift
import XCTest
@testable import WWSwift

final class APIClientTests: XCTestCase {
    func test_post_mockLogout_returnsOK() async throws {
        let env = EnvironmentManager(storage: UserDefaultsStorage(defaults: UserDefaults(suiteName: "APIClientTests")!))
        env.setCurrent(.mock)
        let session = SessionStore(storage: UserDefaultsStorage(defaults: UserDefaults(suiteName: "APIClientTests")!))
        session.accessToken = "test-token"
        let client = APIClient(environment: env, session: session)

        let response: LogoutResponseDTO = try await client.post(
            path: "v1/user/login/logout",
            body: [:]
        )
        XCTAssertEqual(response.code, 0)
    }
}
```

- [ ] **Step 2: 实现 `APIError.swift`**

```swift
import Foundation

struct APIError: Error, Equatable {
    let code: Int
    let message: String
    let isNetworkError: Bool

    static func network(_ underlying: Error) -> APIError {
        APIError(code: -1, message: underlying.localizedDescription, isNetworkError: true)
    }
}
```

- [ ] **Step 3: 实现 `RequestSigning.swift`（P0 最小实现）**

对照 `WeexExchange/Core/NetCore/RequestMap.m` — P0 仅附加 `timestamp` 与空 `sign` 占位，P1 退出联调前补全 HMAC 规则并写入 `docs/api/signing.md`：

```swift
import Foundation

enum RequestSigning {
    static func signedParameters(_ params: [String: Any], token: String?) -> [String: Any] {
        var result = params
        result["timestamp"] = Int(Date().timeIntervalSince1970 * 1000)
        if let token, !token.isEmpty {
            result["token"] = token
        }
        result["sign"] = "TODO_P1_FULL_SIGN"
        return result
    }
}
```

- [ ] **Step 4: 实现 `MockProvider.swift`**

```swift
import Foundation

struct MockProvider {
    func data(forPath path: String) throws -> Data {
        let fileName = path
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Mocks") else {
            throw APIError(code: 404, message: "Mock not found: \(path)", isNetworkError: false)
        }
        return try Data(contentsOf: url)
    }
}
```

创建 `WWSwift/Resources/Mocks/v1_user_login_logout.json`:

```json
{ "code": 0, "msg": "", "data": {} }
```

- [ ] **Step 5: 实现 `APIClient.swift`**

```swift
import Foundation

struct APIResponseDTO<T: Decodable>: Decodable {
    let code: Int
    let msg: String
    let data: T?
}

struct LogoutResponseDTO: Decodable {
    let code: Int
    let msg: String
}

final class APIClient {
    private let environment: EnvironmentManager
    private let session: SessionStore
    private let mockProvider: MockProvider
    private let urlSession: URLSession

    init(
        environment: EnvironmentManager,
        session: SessionStore,
        mockProvider: MockProvider = MockProvider(),
        urlSession: URLSession = .shared
    ) {
        self.environment = environment
        self.session = session
        self.mockProvider = mockProvider
        self.urlSession = urlSession
    }

    func post<T: Decodable>(path: String, body: [String: Any]) async throws -> T {
        if environment.current == .mock {
            let data = try mockProvider.data(forPath: path)
            return try JSONDecoder().decode(T.self, from: data)
        }
        let signed = RequestSigning.signedParameters(body, token: session.accessToken)
        var request = URLRequest(url: environment.url(for: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: signed)
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError(code: -1, message: "HTTP error", isNetworkError: true)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

- [ ] **Step 6: 运行测试并 Commit**

```bash
xcodebuild -workspace WWSwift.xcworkspace -scheme WWSwift -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:WWSwiftTests/APIClientTests test
git add WWSwift/Core/Network/ WWSwift/Resources/Mocks/ WWSwiftTests/Core/APIClientTests.swift
git commit -m "feat: add APIClient with mock provider"
```

---

### Task 5: Environment Debug 页（P0 验收 UI）

**Files:**
- Create: `WWSwift/App/Debug/EnvironmentDebugViewController.swift`

- [ ] **Step 1: 实现 Debug 页（SnapKit）**

```swift
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
        // P1 替换为 LogoutCoordinator；P0 仅验证 API 可调
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
```

- [ ] **Step 2: 模拟器手动验收**

1. 运行 App → Debug Tab  
2. 切换 mock / test，确认 URL 文案变化  
3. 输入 Token → 保存 → 触发退出 → Mock 下弹「成功」且 Token 清空  

- [ ] **Step 3: Commit**

```bash
git add WWSwift/App/Debug/
git commit -m "feat: add environment debug screen"
```

---

### Task 6: 移除 Pod 脚手架

**Files:**
- Delete: `SourceCode/WWSwift.swift`
- Delete: `WWSwift.podspec`
- Modify: `README.md`

- [ ] **Step 1: 删除旧文件并更新 README**

删除 `SourceCode/` 与 `WWSwift.podspec`；README「目录结构」改为指向 `WWSwift/` App 目录（与 spec §5 一致）。

- [ ] **Step 2: Commit**

```bash
git rm -r SourceCode WWSwift.podspec
git add README.md
git commit -m "chore: remove CocoaPods library scaffold in favor of app target"
```

---

### Task 7: Agents / Rules / Skills + API 文档

**Files:**
- Create: `.cursor/rules/wwswift-swift-uikit.mdc`
- Create: `.cursor/rules/wwswift-weexios-parity.mdc`
- Create: `.cursor/rules/wwswift-no-weexios-import.mdc`
- Create: `.cursor/agents/wwswift-architect.md`
- Create: `.cursor/agents/wwswift-contract-port.md`
- Create: `.cursor/agents/wwswift-logout-port.md`
- Create: `.cursor/agents/wwswift-network-env.md`
- Create: `.codex/skills/wwswift-oc-to-swift-contract/SKILL.md`
- Create: `.codex/skills/wwswift-logout-flow/SKILL.md`
- Create: `.codex/skills/wwswift-env-and-api/SKILL.md`
- Create: `docs/api/endpoints.md`

- [ ] **Step 1: 创建 `wwswift-swift-uikit.mdc`**

```markdown
---
description: WWSwift Swift/UIKit 编码约定
globs: WWSwift/**/*.swift
alwaysApply: false
---

- UIKit + SnapKit；禁止 SwiftUI
- 4 空格缩进；`final` 优先
- 布局用 SnapKit，禁止 storyboard 布局业务页
- 新文件放入 App / Core / Features 分层
```

- [ ] **Step 2: 创建 `wwswift-weexios-parity.mdc`**

```markdown
---
description: weexios 功能对齐与跟单排除
globs: WWSwift/**/*.swift
alwaysApply: false
---

禁止参照实现：
- UI/Main/Trade/CopyTrade/**
- WContractCopyTradeController
- WFollowOrderViewController*

对照清单见 docs/reference/weexios-mapping.md
```

- [ ] **Step 3: 创建 `wwswift-no-weexios-import.mdc`**

```markdown
---
description: 禁止依赖 weexios
alwaysApply: true
---

- 不得 import WeexExchange / PHNet / WeexNet
- weexios 路径只读：/Users/lijingyi/Desktop/WW/weexios/WeexExchange
```

- [ ] **Step 4: 创建四个 agent 与三个 skill**

每个 agent/skill 各 15–30 行：职责、必读路径、验收清单（照 spec §7 表格）。

- [ ] **Step 5: 创建 `docs/api/endpoints.md`**

从 `weexios/.../ApiConst.h` 摘录至少：

| Key | Path | 用途 | 阶段 |
|-----|------|------|------|
| logout | `v1/user/login/logout` | 退出 | P1 |
| meta | `api/v1/public/meta/getMetaDataNew` | 合约元数据 | P2 |
| activeOrder | `api/v1/private/order/getActiveOrderPage` | 当前委托 | P2 |
| createOrder | `api/v1/private/order/createOrder` | 下单 | P3 |
| cancelOrderById | `api/v1/private/order/cancelOrderById` | 撤单 | P4 |
| closeAllPosition | `api/v1/private/order/closeAllPosition` | 平仓 | P4 |

- [ ] **Step 6: Commit**

```bash
git add .cursor/ .codex/ docs/api/
git commit -m "docs: add cursor agents, rules, skills, and API endpoint table"
```

---

### P0 完成检查清单

- [ ] `xcodebuild` 通过  
- [ ] 单元测试 `EnvironmentManager` / `SessionStore` / `APIClient` 通过  
- [ ] Debug 页可切换环境、注入 Token、Mock 退出  
- [ ] 无 `SourceCode/`、无 `WWSwift.podspec`  
- [ ] Agents / Rules / Skills 已落地  

---

## Phase P1 — 退出登录链路

**weexios 对照:** `LoginHandler.logout` → `UserManger.cleanUserinfo` → `UINotifyCenter notifyUserLogin:NO`

### Task 8: LogoutService + SideEffects + Coordinator

**Files:**
- Create: `WWSwift/Features/Logout/LogoutService.swift`
- Create: `WWSwift/Features/Logout/LogoutSideEffects.swift`
- Create: `WWSwift/Features/Logout/LogoutCoordinator.swift`
- Create: `WWSwift/Core/Foundation/Notification+App.swift`
- Modify: `WWSwift/App/Debug/EnvironmentDebugViewController.swift`
- Create: `WWSwiftTests/Features/LogoutServiceTests.swift`
- Create: `WWSwift/Resources/Mocks/v1_user_login_logout_fail.json`

- [ ] **Step 1: 写失败测试**

```swift
func test_logout_success_clearsSession() async throws {
    // mock 成功 → session.isLoggedIn == false
}
func test_logout_failure_keepsSession() async throws {
    // mock code != 0 → token 仍在
}
```

- [ ] **Step 2: 实现 `LogoutService`**

```swift
final class LogoutService {
    private let apiClient: APIClient
    private let session: SessionStore
    private let sideEffects: LogoutSideEffectRegistry

    func logout() async -> Result<Void, APIError> {
        do {
            let resp: LogoutResponseDTO = try await apiClient.post(path: "v1/user/login/logout", body: [:])
            guard resp.code == 0 else {
                return .failure(APIError(code: resp.code, message: resp.msg, isNetworkError: false))
            }
            session.clear()
            sideEffects.performAfterLogout()
            return .success(())
        } catch let error as APIError {
            return .failure(error)
        } catch {
            return .failure(.network(error))
        }
    }
}
```

- [ ] **Step 3: 实现 `LogoutSideEffectRegistry`**

对齐 `UserManger.cleanUserinfo` 的 WWSwift 子集（不引入 AssetManager 等 weexios 类）：

```swift
extension Notification.Name {
    static let wwUserDidLogout = Notification.Name("ww.userDidLogout")
}

struct LogoutSideEffectRegistry {
    func performAfterLogout() {
        NotificationCenter.default.post(name: .wwUserDidLogout, object: nil)
        // P1: 清理合约本地缓存键（UserDefaults）
        UserDefaults.standard.removeObject(forKey: "contract_passphrase_cache")
    }
}
```

- [ ] **Step 4: 实现 `LogoutCoordinator`**

- 展示 `UIActivityIndicator`  
- 成功 → Alert + 可选 pop to root  
- 失败 → Alert，**不** clear session  

- [ ] **Step 5: Debug 页改用 Coordinator**

- [ ] **Step 6: 测试 + Commit**

```bash
git commit -m "feat: implement logout flow with side effects"
```

**P1 验收:** Mock 成功/失败；Test 环境用 Debug 注入真实 Token 调 `logout` API。

---

## Phase P2 — 合约骨架（能力 A）

**weexios 对照:** `WContractController` + `WContractHeaderView` + 列表容器

### Task 9: Contract 模型与 ConfigService

**Files:**
- Create: `WWSwift/Features/Contract/Models/ContractSymbol.swift`
- Create: `WWSwift/Features/Contract/Models/ContractOrder.swift`
- Create: `WWSwift/Features/Contract/Models/ContractPosition.swift`
- Create: `WWSwift/Core/Config/ContractConfigService.swift`
- Create: `WWSwift/Resources/Mocks/api_v1_public_meta_getMetaDataNew.json`
- Create: `WWSwiftTests/Features/ContractConfigServiceTests.swift`

- [ ] **Step 1–5:** TDD 拉取 meta（path: `api/v1/public/meta/getMetaDataNew`），解析至少 `contractId`、`symbolName`  
- [ ] **Commit:** `feat: add contract config service`

### Task 10: ContractViewController 骨架

**Files:**
- Create: `WWSwift/Features/Contract/ViewControllers/ContractViewController.swift`
- Create: `WWSwift/Features/Contract/Views/ContractHeaderView.swift`
- Create: `WWSwift/Features/Contract/Views/ContractSegmentView.swift`
- Create: `WWSwift/Features/Contract/ViewModels/ContractViewModel.swift`
- Create: `WWSwift/Features/Contract/Coordinator/ContractCoordinator.swift`
- Modify: `WWSwift/App/MainTabBarController.swift`

- [ ] **UI:** Header（币对名 + 切换按钮）、Segment（持仓 / 当前委托）、`UITableView` 占位  
- [ ] **币对切换:** `UIAlertController` actionSheet 列出 Config 中 symbol  
- [ ] **Mock:** 静态列表数据；Test：调用 `getActiveOrderPage` 展示空态/有数据  
- [ ] **Commit:** `feat: add contract screen skeleton`

**P2 验收:** 切换币对；委托/持仓列表在 Mock/Test 可展示。

---

## Phase P3 — 下单闭环（能力 B）

**weexios 对照:** `WContractPlaceOrder*`、`api_contract_placeOrder`

### Task 11: 下单 Service + 确认弹窗

**Files:**
- Create: `WWSwift/Features/Contract/Services/ContractOrderService.swift`
- Create: `WWSwift/Features/Contract/Views/PlaceOrderPanelView.swift`
- Create: `WWSwift/Features/Contract/ViewControllers/OrderConfirmAlertController.swift`
- Create: `WWSwift/Features/Contract/Models/PlaceOrderRequest.swift`
- Create: `WWSwiftTests/Features/PlaceOrderRequestTests.swift`

- [ ] **TDD:** `PlaceOrderRequest` 校验 limit/market 参数、杠杆、保证金模式枚举  
- [ ] **API:** POST `api/v1/private/order/createOrder`  
- [ ] **UI:** 限价/市价切换、数量输入、下单按钮 → 确认弹窗 → 调 API → Toast  
- [ ] **刷新:** 下单成功后通知 ViewModel reload 委托列表  
- [ ] **Commit:** `feat: add place order flow`

---

## Phase P4 — 仓位/委托管理（能力 C）

**weexios 对照:** `WContractPositionController`、`cancelOrderById`、`updateOrderLimitPrice`

### Task 12: 仓位与委托操作

**Files:**
- Create: `WWSwift/Features/Contract/Services/ContractPositionService.swift`
- Create: `WWSwift/Features/Contract/ViewControllers/PositionActionSheetController.swift`
- Create: `WWSwift/Features/Contract/ViewControllers/EditOrderViewController.swift`
- Create: `WWSwift/Features/Contract/ViewControllers/TPSLViewController.swift`

| 操作 | API path |
|------|----------|
| 撤单 | `api/v1/private/order/cancelOrderById` |
| 改价 | `api/v1/private/order/updateOrderLimitPrice` |
| 止盈止损 | `api/v1/private/order/updateOrderTriggerPrice` |
| 平仓 | `api/v1/private/order/closeAllPosition` 或单笔平仓 API |

- [ ] 每条操作：Mock JSON + ViewModel 测试 + 手动 QA 一条  
- [ ] **Commit:** `feat: add position and order management actions`

---

## Phase P5 — weexios 对照与 gap 清单

### Task 13: weexios-mapping.md

**Files:**
- Create: `docs/reference/weexios-mapping.md`

- [ ] 按 `weexios/.../UI/Main/Trade/Contract/` 目录列出 OC 文件 → Swift 目标文件 → 状态（完成/占位/排除）  
- [ ] 跟单相关文件标记 **EXCLUDED**  
- [ ] 记录已知差异（签名简化、WS 未实现、域名写死等）  
- [ ] **Commit:** `docs: add weexios mapping and gap list`

---

## Spec 覆盖自检

| Spec 章节 | 计划任务 |
|-----------|----------|
| §1 背景目标 | P0–P5 全阶段 |
| §2 非目标 | Rules + mapping EXCLUDED |
| §3 合约 A+B+C | P2 / P3 / P4 |
| §4 退出登录 | P1 |
| §5 工程结构 | Task 1–7 |
| §6 网络环境 | Task 3–5 |
| §7 Agents/Rules/Skills | Task 7 |
| §8 分阶段 | P0–P5 各 Phase |
| §9 Podfile | Task 1 |
| §10 错误处理/测试 | APIError + XCTest 各 Task |
| §11 风险 | endpoints.md、Debug URL、mapping |
| §12 决策 | 全文遵循 |

**Placeholder 扫描:** 仅 `RequestSigning` 的 `TODO_P1_FULL_SIGN` 与 P2+ 行情 WS — 已在 P1 Task 标注必须补全。

---

## 可选：P0 后 CI

**Files:** Create `.github/workflows/ios.yml`

```yaml
name: iOS Build
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - run: brew install xcodegen cocoapods
      - run: xcodegen generate && pod install
      - run: xcodebuild -workspace WWSwift.xcworkspace -scheme WWSwift -destination 'platform=iOS Simulator,name=iPhone 16' build test
```

---

## 执行顺序摘要

```
P0 (Task 1–7) → 可编译 Demo + Debug
P1 (Task 8)   → 正式退出链路
P2 (Task 9–10) → 合约骨架
P3 (Task 11)  → 下单
P4 (Task 12)  → 仓位/委托管理
P5 (Task 13)  → 对照文档
```
