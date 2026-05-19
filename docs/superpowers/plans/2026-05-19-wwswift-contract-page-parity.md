# 合约页视觉与数据对齐 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 WWSwift 合约页从极简纵向布局升级为 weexios 主交易屏结构（左下单+右盘口+底栏列表），并按 M1→M2→M3 接入 PHNet 真实数据。

**Architecture:** 保留 View→ViewModel→Coordinator→Service→APIClient 分层；M1 巩固 PHNet 混合网络（`APIClient` 门面 + `PHNetBootstrap`）；M2 按区块拆 View、VC 仅装配；M3 扩展 Socket/REST Service 并向 ViewModel 喂数。

**Tech Stack:** iOS 14+、Swift 5、UIKit、SnapKit、PHNet.xcframework、AFNetworking、XcodeGen、XCTest

**Spec:** [`docs/superpowers/specs/2026-05-19-wwswift-contract-page-parity-design.md`](../specs/2026-05-19-wwswift-contract-page-parity-design.md)  
**本机路径:** `/Users/lijingyi/Desktop/WW/AITest/WWSwift`  
**weexios 只读:** `/Users/lijingyi/Desktop/WW/weexios/WeexExchange`

**基线说明（2026-05-19）：** `PHNetBootstrap`、`APIClient.postViaPHNet`、`ContractMarketSocketService`（301/310）已存在。M1 以**验收 + 文档 + Token 重连**为主，勿重复实现。

---

## 文件结构总览（M2 结束时）

| 路径 | 职责 |
|------|------|
| `WWSwift/Features/Contract/Views/Header/*` | Header + 杠杆栏 |
| `WWSwift/Features/Contract/Views/PlaceOrder/*` | 下单区子 View + 容器 |
| `WWSwift/Features/Contract/Views/OrderBook/ContractOrderBookView.swift` | 盘口 |
| `WWSwift/Features/Contract/Views/BottomList/*` | 底栏 Segmented/Toolbar/Cell/空态 |
| `WWSwift/Features/Contract/Models/ContractOrderBookSnapshot.swift` | 盘口快照 |
| `WWSwift/Features/Contract/Models/ContractTradeSettings.swift` | 交易设置 |
| `WWSwift/Features/Contract/Services/ContractAccountService.swift` | M3 账户 |
| `WWSwift/Features/Contract/Services/ContractOrderBookSocketService.swift` | M3 盘口 Socket |
| `WWSwift/Features/Contract/Services/ContractTradeSettingsStore.swift` | 杠杆/模式持久化 |
| `docs/api/signing.md` | M1 签名说明 |

---

# Milestone M1 — 网络底座验收与补强

### Task M1-1: 编写 `docs/api/signing.md`

**Files:**
- Create: `docs/api/signing.md`
- Modify: `docs/api/endpoints.md`（删除 `RequestSigning` 待实现表述）

- [ ] **Step 1: 创建 signing 文档**

```markdown
# HTTP / Socket 签名（WWSwift）

WWSwift **不在 Swift 中复刻** weexios `RequestMap` HMAC。签名由 **PHNet** 承担：

| 层 | 类 | 职责 |
|----|-----|------|
| HTTP header | `WeexHttpClient.configHeader` | 由 `PHNetBootstrap.buildHTTPHeader` 注入 u-token、X-SIG、sidecar 等 |
| Socket header | `RuntimeAPPEnv.socketHeader` | `PHNetBootstrap.buildSocketHeader` |
| sidecar | `SecurityManager.getSideCarSign` | PHNet 内部 |

业务代码统一经 `APIClient.post(path:body:)`；Mock 环境走 `MockProvider`，不经过 PHNet。
```

- [ ] **Step 2: 更新 `endpoints.md` 第 3 条**

将「`RequestSigning`（待实现）」改为「经 `APIClient` → PHNet `WeexHttpClient`」。

- [ ] **Step 3: Commit**

```bash
git add docs/api/signing.md docs/api/endpoints.md
git commit -m "docs: document PHNet signing bridge for APIClient"
```

---

### Task M1-2: Token 变更后刷新 Socket

**Files:**
- Modify: `WWSwift/App/Debug/EnvironmentDebugViewController.swift`
- Modify: `WWSwift/Core/Network/SocketBootstrap.swift`

- [ ] **Step 1: 在 `SocketBootstrap` 增加 `reconnect()`**

```swift
enum SocketBootstrap {
    // ... existing start/onAppForeground ...

    static func reconnect() {
        SocketManager.getInstance().stop()
        SocketManager.getInstance().start()
    }
}
```

- [ ] **Step 2: Debug 页保存 token 后调用**

在 `EnvironmentDebugViewController` 保存 `accessToken`/`userToken`/`rToken` 的按钮 handler 末尾：

```swift
SocketBootstrap.reconnect()
```

- [ ] **Step 3: 手动验证**

1. 切到 **test** 环境  
2. 注入三 token  
3. 观察合约页 Header `socketConnected` 为 true（或日志无鉴权错误）

- [ ] **Step 4: Commit**

```bash
git add WWSwift/Core/Network/SocketBootstrap.swift WWSwift/App/Debug/EnvironmentDebugViewController.swift
git commit -m "fix: reconnect socket after debug token injection"
```

---

### Task M1-3: `getMetaDataNew` 集成测试（Test 环境可选）

**Files:**
- Create: `WWSwiftTests/Core/ContractConfigServicePHNetTests.swift`

- [ ] **Step 1: 添加可跳过集成测试**

```swift
import XCTest
@testable import WWSwift

final class ContractConfigServicePHNetTests: XCTestCase {
  func testFetchSymbols_integration_skippedByDefault() throws {
    try XCTSkipIf(ProcessInfo.processInfo.environment["WWSWIFT_PHNET_IT"] != "1",
                  "Set WWSWIFT_PHNET_IT=1 and inject tokens to run")
    let env = EnvironmentManager()
    env.setCurrent(.test, syncToPHNet: true)
    let session = SessionStore()
    // 从环境变量读取 token 或硬编码本地测试 token（勿提交真实 token）
    let api = APIClient(environment: env, session: session, mockProvider: MockProvider())
    let svc = ContractConfigService(apiClient: api)
    let exp = expectation(description: "meta")
    Task {
      let result = await svc.fetchSymbols()
      if case .success(let list) = result { XCTAssertFalse(list.isEmpty) }
      else { XCTFail("expected success") }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 30)
  }
}
```

- [ ] **Step 2: 运行单元测试（默认跳过集成）**

```bash
xcodebuild test -workspace WWSwift.xcworkspace -scheme WWSwift -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:WWSwiftTests 2>&1 | tail -20
```

Expected: 全部 PASS（集成用例 SKIP）

- [ ] **Step 3: Commit**

```bash
git add WWSwiftTests/Core/ContractConfigServicePHNetTests.swift
git commit -m "test: add optional PHNet integration test for contract meta"
```

---

### Task M1-4: M1 验收与 mapping 更新

**Files:**
- Modify: `docs/reference/weexios-mapping.md`

- [ ] **Step 1: 更新 mapping 表网络行**

| 行 | 新状态 |
|----|--------|
| `DomainManager` / `PHNet` | PARTIAL → **DONE**（环境切换 + Bootstrap） |
| `RequestMap` 签名 | 删除或标 **DONE（PHNet）** |
| `WeexHttpClient` | PARTIAL → **DONE** |

- [ ] **Step 2: 勾选 Spec M1 验收清单**

- [ ] **Step 3: Commit**

```bash
git add docs/reference/weexios-mapping.md
git commit -m "docs: mark PHNet network layer DONE in weexios mapping"
```

---

# Milestone M2 — UI 视觉对齐（Mock 数据）

### Task M2-1: 模型与 Mock 盘口

**Files:**
- Create: `WWSwift/Features/Contract/Models/ContractOrderBookSnapshot.swift`
- Create: `WWSwift/Features/Contract/Models/ContractTradeSettings.swift`

- [ ] **Step 1: `ContractOrderBookSnapshot`**

```swift
struct ContractOrderBookLevel: Equatable {
  let price: String
  let size: String
}

struct ContractOrderBookSnapshot: Equatable {
  let bids: [ContractOrderBookLevel]   // 买一在上，共 5 档
  let asks: [ContractOrderBookLevel]   // 卖一在上，共 5 档
  let lastPrice: String
  let pricePrecision: Int

  static func mock(lastPrice: String = "97234.5") -> ContractOrderBookSnapshot {
    let asks = (0..<5).map { i in ContractOrderBookLevel(price: String(format: "%.1f", (Double(lastPrice)! + Double(i+1)*0.5)), size: "1.234") }
    let bids = (0..<5).map { i in ContractOrderBookLevel(price: String(format: "%.1f", (Double(lastPrice)! - Double(i+1)*0.5)), size: "0.987") }
    return ContractOrderBookSnapshot(bids: bids, asks: asks, lastPrice: lastPrice, pricePrecision: 1)
  }
}
```

- [ ] **Step 2: `ContractTradeSettings`**

```swift
enum MarginMode: String, CaseIterable { case isolated = "逐仓"; case cross = "全仓" }
enum OpenCloseMode: Int, CaseIterable { case open = 0; case close = 1 }

struct ContractTradeSettings: Equatable {
  var leverage: Int = 20
  var marginMode: MarginMode = .isolated
  var openCloseMode: OpenCloseMode = .open
}
```

- [ ] **Step 3: Commit**

```bash
git add WWSwift/Features/Contract/Models/ContractOrderBookSnapshot.swift WWSwift/Features/Contract/Models/ContractTradeSettings.swift
git commit -m "feat(contract): add order book snapshot and trade settings models"
```

---

### Task M2-2: 扩展 `ContractViewModel` UI 状态

**Files:**
- Modify: `WWSwift/Features/Contract/ViewModels/ContractViewModel.swift`
- Create: `WWSwiftTests/Features/ContractViewModelUIStateTests.swift`

- [ ] **Step 1: 添加属性**

```swift
private(set) var tradeSettings = ContractTradeSettings()
private(set) var orderBook: ContractOrderBookSnapshot = .mock()
private(set) var fundingRateText: String = "0.0100%"
private(set) var fundingCountdownText: String = "07:59:59"
private(set) var availableBalanceText: String = "-- USDT"
private(set) var maxOpenLongText: String = "--"
private(set) var maxOpenShortText: String = "--"
private(set) var costPreviewText: String = "-- USDT"
```

- [ ] **Step 2: 添加更新方法（M2 仅本地）**

```swift
func updateSizePercent(_ percent: Float) { /* 更新 size 文案 */ onUpdate?() }
func setOpenCloseMode(_ mode: OpenCloseMode) { tradeSettings.openCloseMode = mode; onUpdate?() }
func setLeverage(_ value: Int) { tradeSettings.leverage = value; onUpdate?() }
```

- [ ] **Step 3: 写测试 `testSetOpenCloseMode_updatesSettings`**

- [ ] **Step 4: Commit**

```bash
git add WWSwift/Features/Contract/ViewModels/ContractViewModel.swift WWSwiftTests/Features/ContractViewModelUIStateTests.swift
git commit -m "feat(contract): extend view model with M2 UI state"
```

---

### Task M2-3: Header + 杠杆栏

**Files:**
- Modify: `WWSwift/Features/Contract/Views/ContractHeaderView.swift` → 移至 `Views/Header/ContractHeaderView.swift`
- Create: `WWSwift/Features/Contract/Views/Header/LeverageBarView.swift`

- [ ] **Step 1: 增强 `ContractHeaderView`**

显示：`symbolName`、永续标签、`lastPrice`、24h 涨跌幅（绿/红）、socket 绿点/灰点。

公开 API：

```swift
func updateTicker(symbol: String, lastPrice: String, changePercent: String, isUp: Bool)
func updateSocketStatus(connected: Bool)
```

- [ ] **Step 2: `LeverageBarView`**

左侧显示 `20x` + 逐仓/全仓；右侧「调整」按钮 → 回调 `onAdjustLeverageTapped`（M2 仅 Alert 占位）。

- [ ] **Step 3: 更新 `project.yml` / XcodeGen 无需改（目录在 `WWSwift/` 下递归）**

- [ ] **Step 4: Commit**

```bash
git add WWSwift/Features/Contract/Views/Header/
git commit -m "feat(contract): enhance header and add leverage bar"
```

---

### Task M2-4: PlaceOrder 子 View 拆分

**Files:**
- Create: `WWSwift/Features/Contract/Views/PlaceOrder/*.swift`（8 个文件）
- Modify: `WWSwift/Features/Contract/Views/PlaceOrderPanelView.swift` → `Views/PlaceOrder/PlaceOrderPanelView.swift`

- [ ] **Step 1: 逐个创建子 View（UIKit + SnapKit）**

| 文件 | 职责 |
|------|------|
| `FundingRateBarView` | 费率 + 倒计时 |
| `OpenCloseTabView` | 开仓/平仓 segmented |
| `OrderTypeSelectorView` | 限价/市价 |
| `PriceSizeInputView` | 价格、数量输入 |
| `SizeSliderView` | 0–100% 滑块 |
| `AvailableBalanceView` | 可用/可开 |
| `TpSlToggleView` | TP/SL 开关 |
| `CostPreviewView` | 成本 |
| `PlaceOrderButtonsView` | 买入开多/卖出开空 |

- [ ] **Step 2: `PlaceOrderPanelView` 用垂直 `UIStackView` 组装**

对外保留：

```swift
var onPlaceOrder: ((PlaceOrderRequest) -> Void)?
func bind(viewModel: ContractViewModel)  // 或逐字段 configure
```

- [ ] **Step 3: 确保 `PlaceOrderRequest` 构建逻辑与现有一致**

- [ ] **Step 4: Commit**

```bash
git add WWSwift/Features/Contract/Views/PlaceOrder/
git commit -m "feat(contract): split place order panel into subviews"
```

---

### Task M2-5: 盘口 View

**Files:**
- Create: `WWSwift/Features/Contract/Views/OrderBook/ContractOrderBookView.swift`

- [ ] **Step 1: 实现 5 档卖 + 最新价 + 5 档买**

```swift
final class ContractOrderBookView: UIView {
  func update(snapshot: ContractOrderBookSnapshot)
}
```

卖档红色、买档绿色；最新价居中加粗。

- [ ] **Step 2: Commit**

```bash
git add WWSwift/Features/Contract/Views/OrderBook/ContractOrderBookView.swift
git commit -m "feat(contract): add order book view with mock snapshot"
```

---

### Task M2-6: 底栏列表

**Files:**
- Create: `WWSwift/Features/Contract/Views/BottomList/*.swift`
- Delete: `WWSwift/Features/Contract/Views/ContractSegmentView.swift`（逻辑迁移后）

- [ ] **Step 1: `BottomSegmentedView`** — 持仓 | 当前委托

- [ ] **Step 2: `BottomToolbarView`** — 「只看当前合约」Switch + 「一键平仓」按钮（M2 弹 Alert 占位）

- [ ] **Step 3: `ContractPositionCell` / `ContractOrderCell`** — 多行 label，展示 symbol/方向/数量/盈亏

- [ ] **Step 4: `EmptyStateView`** — 无数据 + 「充值」「划转」按钮（无跟单）

- [ ] **Step 5: Commit**

```bash
git add WWSwift/Features/Contract/Views/BottomList/
git rm WWSwift/Features/Contract/Views/ContractSegmentView.swift
git commit -m "feat(contract): add bottom list views and cells"
```

---

### Task M2-7: 重组 `ContractViewController` 布局

**Files:**
- Modify: `WWSwift/Features/Contract/ViewControllers/ContractViewController.swift`

- [ ] **Step 1: 布局结构**

```swift
// pseudo
let topRow = UIStackView(arrangedSubviews: [leftColumn, orderBookView])
leftColumn.addArrangedSubview(leverageBar)
leftColumn.addArrangedSubview(placeOrderPanel)
// header 单独置顶
// bottomSegment + toolbar + tableView
```

- [ ] **Step 2: `render()` 绑定 viewModel**

- `headerView.updateTicker` / `updateSocketStatus`
- `orderBookView.update(snapshot:)`
- `tableView` 使用新 Cell

- [ ] **Step 3: 删除对 `ContractSegmentView` 引用，改用 `BottomSegmentedView`**

- [ ] **Step 4: 编译运行模拟器，截图对比**

```bash
xcodegen generate && pod install
xcodebuild build -workspace WWSwift.xcworkspace -scheme WWSwift -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5
```

- [ ] **Step 5: Commit**

```bash
git add WWSwift/Features/Contract/ViewControllers/ContractViewController.swift
git commit -m "feat(contract): reorganize contract screen layout for M2"
```

---

### Task M2-8: M2 验收

- [ ] **Step 1: 运行全部单元测试**

- [ ] **Step 2: Mock 环境点通下单 → 确认弹窗 → 列表刷新**

- [ ] **Step 3: 更新 `weexios-mapping.md` 合约 UI 行为 PARTIAL → 注明 M2 布局完成**

- [ ] **Step 4: Commit docs**

```bash
git add docs/reference/weexios-mapping.md
git commit -m "docs: note contract UI layout parity after M2"
```

---

# Milestone M3 — 实盘数据

### Task M3-1: `ContractOrderBookSocketService`

**Files:**
- Create: `WWSwift/Features/Contract/Services/ContractOrderBookSocketService.swift`
- Modify: `WWSwift/App/AppDelegate.swift`（register receiver）

- [ ] **Step 1: 对照 weexios `WContractOrderBookView` 订阅**

在 `ContractMarketSocketService` 同模式注册 `TYPE_SOCKET_CONTRACT_ORDER_BOOK`（具体常量名以 PHNet header 为准，只读对照 weexios）。

- [ ] **Step 2: API**

```swift
func subscribe(contractId: String)
func unsubscribe(contractId: String)
var onSnapshot: ((ContractOrderBookSnapshot) -> Void)?
```

- [ ] **Step 3: `ContractViewModel` 在 `selectSymbol` 时切换订阅**

- [ ] **Step 4: Commit**

```bash
git add WWSwift/Features/Contract/Services/ContractOrderBookSocketService.swift WWSwift/App/AppDelegate.swift WWSwift/Features/Contract/ViewModels/ContractViewModel.swift
git commit -m "feat(contract): subscribe order book via PHNet socket"
```

---

### Task M3-2: 资金费率 Socket

**Files:**
- Modify: `WWSwift/Features/Contract/Services/ContractMarketSocketService.swift`（或新建 `ContractFundingRateService.swift`）

- [ ] **Step 1: 注册 funding rate 推送类型**

- [ ] **Step 2: `ContractViewModel` 更新 `fundingRateText` / `fundingCountdownText`**

- [ ] **Step 3: Commit**

```bash
git commit -m "feat(contract): wire funding rate socket to view model"
```

---

### Task M3-3: `ContractAccountService`

**Files:**
- Create: `WWSwift/Features/Contract/Services/ContractAccountService.swift`
- Modify: `docs/api/endpoints.md`

- [ ] **Step 1: 只读对照 weexios `AssetManager` / 下单页余额 API path**

- [ ] **Step 2: 实现 `fetchAvailableBalance(contractId:) async -> Result<Decimal, APIError>`**

- [ ] **Step 3: ViewModel 在 `loadInitialData` / 下单前 refresh**

- [ ] **Step 4: 摘录 endpoint 到 `endpoints.md`**

- [ ] **Step 5: Commit**

```bash
git add WWSwift/Features/Contract/Services/ContractAccountService.swift docs/api/endpoints.md
git commit -m "feat(contract): add account service for available balance"
```

---

### Task M3-4: 真实持仓 REST

**Files:**
- Modify: `WWSwift/Features/Contract/Services/ContractPositionService.swift`

- [ ] **Step 1: 非 Mock 环境走 `APIClient.post` 真实 path**

- [ ] **Step 2: 解析 DTO → `[ContractPosition]`**

- [ ] **Step 3: 单元测试：Mock JSON fixture**

- [ ] **Step 4: Commit**

```bash
git commit -m "feat(contract): fetch real positions on test environment"
```

---

### Task M3-5: 可开/成本计算（简化）

**Files:**
- Modify: `WWSwift/Features/Contract/ViewModels/ContractViewModel.swift`

- [ ] **Step 1: 对照 weexios 公式实现 `recalculatePreview()`**

输入：杠杆、价格、数量、余额 → 输出 `maxOpenLongText` 等。

- [ ] **Step 2: 在 price/size/leverage 变化时调用**

- [ ] **Step 3: 测试固定输入输出**

- [ ] **Step 4: Commit**

```bash
git commit -m "feat(contract): simplify max-open and cost preview calculation"
```

---

### Task M3-6: M3 验收

- [ ] **Step 1: test 环境 + token — 价格跳动、盘口更新**

- [ ] **Step 2: 下单后当前委托列表为真实数据**

- [ ] **Step 3: 更新 `weexios-mapping.md` 合约为 DONE/PARTIAL 准确状态**

- [ ] **Step 4: Commit**

```bash
git commit -m "docs: finalize contract parity mapping after M3"
```

---

## Self-Review（计划 vs Spec）

| Spec 章节 | 覆盖任务 |
|-----------|----------|
| M1 PHNet | M1-1 ~ M1-4 |
| M2 布局/目录 | M2-1 ~ M2-8 |
| M3 Socket/REST | M3-1 ~ M3-6 |
| 错误处理 | M1-2、M3 ViewModel 禁用态 |
| 非目标 | 计划无跟单/K线/5-Tab 任务 |

**Placeholder 扫描:** 无 TBD；M3-1 要求实施时从 PHNet header 读取确切 socket type 常量名。

---

## 执行方式

计划已保存。可选：

1. **Subagent-Driven（推荐）** — 每 Task 派生子 agent + 阶段评审  
2. **Inline Execution** — 本会话按 `executing-plans` 批量执行并设检查点  

请告知选用哪种方式；若从 M1 开始，可先执行 **M1-1**（文档）与 **M1-2**（Socket 重连）。
