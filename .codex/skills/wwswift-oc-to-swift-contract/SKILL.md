---
name: wwswift-oc-to-swift-contract
description: 将 weexios 合约 OC/UI 对照迁移为 WWSwift UIKit+SnapKit 实现；排除跟单。用于合约页、下单、仓位/委托管理相关任务。
---

# 合约 OC → Swift 迁移

## 何时使用

- 新增/改写 `WWSwift/Features/Contract/**`
- 对照 weexios `UI/Main/Trade/Contract/` 行为

## 只读对照路径

`/Users/lijingyi/Desktop/WW/weexios/WeexExchange/WeexExchange/UI/Main/Trade/Contract/`

## 排除（不得移植）

- `CopyTrade/**`
- `WContractCopyTradeController`
- `WFollowOrderViewController*`

## 迁移步骤

1. 在 weexios 定位 VC/View/Manager 与 API 调用点。
2. 将 path 登记到 `docs/api/endpoints.md`（Key / Phase）。
3. 新建 Swift：`final class` + SnapKit；DTO 放 `Features/Contract/Models/` 或 `Core/`。
4. 经 `APIClient` 请求；mock JSON 放 `WWSwift/Resources/Mocks/`。
5. 为 Service 写 `WWSwiftTests`；UI 可后补。

## 分阶段验收

| Phase | 能力 | 关键 API |
|-------|------|----------|
| P2 | 骨架 + meta | `getMetaDataNew`、`getActiveOrderPage` |
| P3 | 下单 | `createOrder` |
| P4 | 仓位/委托 | `cancelOrderById`、`closeAllPosition` |

## 完成标准

- [ ] 无 SwiftUI / 无 weexios import
- [ ] 跟单零引用
- [ ] endpoint 表已更新
