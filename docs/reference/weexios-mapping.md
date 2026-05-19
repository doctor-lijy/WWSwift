# weexios → WWSwift 对照映射

**日期：** 2026-05-19  
**weexios 只读路径：** `/Users/lijingyi/Desktop/WW/weexios/WeexExchange`  
**WWSwift 路径：** `/Users/lijingyi/Desktop/WW/AITest/WWSwift`  
**Spec：** [`docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md`](../superpowers/specs/2026-05-19-wwswift-standalone-design.md)

---

## 状态图例

| 状态 | 含义 |
|------|------|
| **DONE** | 已有 Swift 等价实现，核心行为可测 |
| **PARTIAL** | 骨架/简化实现，与 weexios 有已知差异 |
| **PLACEHOLDER** | 仅占位或 Mock，未接真实 API/完整 UI |
| **OUT_OF_SCOPE** | spec 明确不纳入本仓库 |
| **EXCLUDED** | 跟单相关，禁止参照 |

---

## 1. 工程与基础设施

| weexios | WWSwift | 状态 | 备注 |
|---------|---------|------|------|
| `DomainManager` / `PHNet` | `EnvironmentManager` + `APIClient` | PARTIAL | 域名写死常量；未实现 `pullNetConfigFile`、线路切换 |
| `RequestMap` 签名 | `RequestSigning` | PARTIAL | P0 占位 `TODO_P1_FULL_SIGN`，未对齐 HMAC |
| `WeexHttpClient` | `APIClient` + `URLSession` | PARTIAL | Mock 走 `MockProvider` |
| `WCacheUtil` (`currentEnv`) | `UserDefaultsStorage` + `currentEnv` 键 | DONE | |
| `UserManger` / `SP_KEY_TOKEN` | `SessionStore` | DONE | |
| `LoginHandler.logout` | `LogoutService` | DONE | path: `v1/user/login/logout` |
| `UserManger.cleanUserinfo` | `LogoutSideEffectRegistry` | PARTIAL | 仅子集：通知 + `contract_passphrase_cache` |
| `WLoginManager.logOutCallBack` | `LogoutCoordinator` | DONE | |
| `WChangeEngViewController` | `EnvironmentDebugViewController` | PARTIAL | 环境切换 + Token 注入 |
| — | `.cursor/rules` + `.cursor/agents` + `.codex/skills` | DONE | P0 |
| — | `docs/api/endpoints.md` | PARTIAL | 核心 endpoint 已摘录 |

---

## 2. 合约模块 — Controller

| weexios (Contract/Controller) | WWSwift | 状态 | 备注 |
|-------------------------------|---------|------|------|
| `WContractController` | `ContractViewController` + `ContractViewModel` | PARTIAL | 主容器；无 K 线/盘口完整集成 |
| `WContractBaseController` | — | PARTIAL | 逻辑合并进 `ContractViewController` |
| `WContractPositionController` | `ContractViewModel`（持仓 segment） | PARTIAL | 持仓为 Mock 数据 |
| `WContractEntrustCurrentController` | `ContractViewModel`（当前委托 segment） | PARTIAL | Mock/Test 拉 `getActiveOrderPage` |
| `WContractLimitOrderController` | — | OUT_OF_SCOPE | 子 Tab 拆分；合并到主列表 |
| `WContractPlanOrderController` | — | OUT_OF_SCOPE | 计划委托未单独分页 |
| `WContractTrailingStopController` | — | OUT_OF_SCOPE | 追踪止损未实现 |
| `WContractController+TradFi` | — | OUT_OF_SCOPE | TradFi 专项 |
| `WContractCopyTradeController` | — | **EXCLUDED** | 跟单 |
| `WFollowOrderViewController` | — | **EXCLUDED** | 跟单 |
| `WFollowOrderViewControllerV2` | — | **EXCLUDED** | 跟单 |

---

## 3. 合约模块 — 下单 (PlaceOrder)

| weexios (View/PlaceOrder + AlertView) | WWSwift | 状态 | 备注 |
|---------------------------------------|---------|------|------|
| `WContractPlaceOrderView` | `PlaceOrderPanelView` | PARTIAL | 限价/市价、买卖、杠杆、保证金简化 |
| `WContractPlaceOrderTextFieldBoxView` | `PlaceOrderPanelView` | PARTIAL | 未拆分 TP/SL、计划委托、GTD |
| `WContractPlaceOrderBtnBoxView` | `PlaceOrderPanelView` | PARTIAL | 单「下单」按钮 |
| `WPlaceOrderConfirmView` / `PlaceOrderConfirmView` | `OrderConfirmAlertController` | PARTIAL | `UIAlertController` 确认 |
| `WContractPlaceOrderTpSlBoxView` | — | PLACEHOLDER | 开仓 TP/SL 未实现 |
| `WContractPlaceOrderPlanGuaranteedSlPriceBoxView` | — | OUT_OF_SCOPE | 计划委托保价 |
| `ContractTradeManager.requestPlaceOrder` | `ContractOrderService` | PARTIAL | `createOrder`；参数为简化集 |

---

## 4. 合约模块 — 仓位/委托操作

| weexios | WWSwift | 状态 | 备注 |
|---------|---------|------|------|
| `cancelOrderById` | `ContractPositionService.cancelOrder` | DONE | Mock 可测 |
| `modifyLimitOrder` | `EditOrderViewController` + `updateLimitPrice` | PARTIAL | 简化改价 UI |
| `modifyPlanOrder` / TP-SL 弹窗 | `TPSLViewController` + `updateTriggerPrice` | PARTIAL | 委托 TP/SL；仓位 TP/SL 占位 |
| `closeAllPosition` | `ContractPositionService.closeAllPositions` | DONE | Mock 可测 |
| `EntrustOrderModifyAlert` | `EditOrderViewController` | PARTIAL | |
| `PositionTpSlSetAlert` 等 | `TPSLViewController` | PARTIAL | |
| `PositionActionSheet` 类交互 | `PositionActionSheetController` | PARTIAL | ActionSheet 简化 |
| `WContractPositionAlertView` | — | PLACEHOLDER | 未实现详细仓位弹窗 |

---

## 5. 合约模块 — 配置与数据

| weexios | WWSwift | 状态 | 备注 |
|---------|---------|------|------|
| `WContractConfigHandler` / `getMetaDataNew` | `ContractConfigService` | PARTIAL | 解析 `contractId` + `contractName` |
| `ContractTradeManager.getCurrOrderList` | `ContractTradingService.fetchActiveOrders` | PARTIAL | |
| Socket 行情 / 盘口 | — | PLACEHOLDER | 未实现 WS；Header 无行情价 |
| `WContractHeaderView`（行情区） | `ContractHeaderView` | PARTIAL | 仅币对名 + 切换 |

---

## 6. 明确排除目录（OUT_OF_SCOPE / EXCLUDED）

### 6.1 spec OUT_OF_SCOPE（不参照）

| 目录/模块 | 文件规模（约） | 说明 |
|-----------|----------------|------|
| `Contract/TradeHistory/**` | 全套 | 历史订单/成交页 |
| `Contract/Calculate/**` | 计算器 | |
| `Contract/Expand/**` | 设置、资金记录等 | 含部分跟单设置 VC |
| `Contract/View/OrderBook/**` | 盘口深度 | P2 占位未做 |
| `Contract/AlertView/**`（大部分） | 30+ 子目录 | 仅映射已实现的改价/确认/TP-SL |

### 6.2 跟单 EXCLUDED

| 路径 | 说明 |
|------|------|
| `UI/Main/Trade/CopyTrade/**` | 整个跟单模块 |
| `WContractCopyTradeController` | 合约内跟单入口 |
| `WFollowOrderViewController*` | 跟单订单 |
| `Expand/vc/WCopyTradeSettingViewController` | 跟单设置 |

---

## 7. 退出登录对照

| weexios | WWSwift | 状态 |
|---------|---------|------|
| `LoginHandler.logout` | `LogoutService` | DONE |
| `UserManger.cleanUserinfo` | `LogoutSideEffectRegistry` | PARTIAL |
| `WUserInfoController` 触发退出 | `EnvironmentDebugViewController` | PARTIAL | 无正式个人中心页 |
| `UINotifyCenter notifyUserLogin` | `Notification.Name.wwUserDidLogout` | PARTIAL |

---

## 8. 分阶段验收对照（P0–P5）

| 阶段 | spec 要求 | WWSwift 状态 |
|------|-----------|--------------|
| **P0** | 工程、环境、Mock、Debug、Agents | **DONE** |
| **P1** | 退出登录 | **DONE**（签名仍 PARTIAL） |
| **P2** | 合约骨架、Config、列表 | **PARTIAL**（持仓 Mock、无 WS） |
| **P3** | 下单闭环 | **PARTIAL**（下单区简化） |
| **P4** | 仓位/委托管理 | **PARTIAL**（仓位 TP/SL 占位） |
| **P5** | 本文档 | **DONE** |

---

## 9. 已知差异与后续 Gap 清单

| # | 类别 | 差异描述 | 建议优先级 |
|---|------|----------|------------|
| G1 | 网络 | `RequestSigning` 未对齐 weexios HMAC/公共参数 | P1 联调前 |
| G2 | 网络 | 环境域名未接 `pullNetConfigFile` 动态配置 | 中 |
| G3 | 行情 | 无 WebSocket 订阅、无 K 线/盘口 | 中 |
| G4 | 持仓 | 持仓列表为 Mock，未接真实仓位 API | 高 |
| G5 | 下单 | 无计划委托、追踪止损、BBO、GTD 保价 | 低 |
| G6 | 下单 | 杠杆/保证金模式 UI 简化，未接 `updateLeverageSetting` | 中 |
| G7 | TP/SL | 仓位维度 TP/SL 仅 Toast 占位 | 中 |
| G8 | 退出 | `cleanUserinfo` 大量副作用未移植（资产、跟单、统计 SDK 等） | 按产品要求 |
| G9 | 登录 | 无完整登录 UI，仅 Debug 注入 Token | spec 非目标 |
| G10 | 测试 | 无 UI 自动化；Test 环境需人工 QA | 持续 |
| G11 | CI | 未配置 GitHub Actions `xcodebuild` | 低 |

---

## 10. WWSwift 合约文件索引（便于检索）

```
WWSwift/Features/Contract/
├── Coordinator/ContractCoordinator.swift
├── Models/ContractSymbol.swift | ContractOrder.swift | ContractPosition.swift | PlaceOrderRequest.swift
├── Services/ContractConfigService.swift | ContractTradingService.swift | ContractOrderService.swift | ContractPositionService.swift
├── ViewControllers/ContractViewController.swift | OrderConfirmAlertController.swift | EditOrderViewController.swift | TPSLViewController.swift | PositionActionSheetController.swift
├── ViewModels/ContractViewModel.swift
└── Views/ContractHeaderView.swift | ContractSegmentView.swift | PlaceOrderPanelView.swift
```

**weexios Contract 源文件统计：** 约 263 个 `.h/.m`（含子目录），本仓库已实现核心路径约 **15% 文件数、~60% P0–P4 主流程能力（简化版）**。

---

## 11. 维护约定

- 新增 Swift 合约文件时，更新 §10 并补充 §2–§5 对应行。
- 新 API 写入 `docs/api/endpoints.md` 并标注 Phase。
- 跟单相关需求一律标记 **EXCLUDED**，不创建实现任务。
