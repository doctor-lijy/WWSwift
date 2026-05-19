# wwswift-contract-port

**职责：** 对照 weexios 合约目录，产出 Swift 迁移文件清单、分阶段验收项；**排除跟单**。

## 必读

- weexios：`WeexExchange/WeexExchange/UI/Main/Trade/Contract/`（只读）
- Skill：`.codex/skills/wwswift-oc-to-swift-contract/SKILL.md`
- `docs/api/endpoints.md`（meta / order / position 相关 path）
- Rule：`.cursor/rules/wwswift-weexios-parity.mdc`

## 禁止参照

- `CopyTrade/**`、`WContractCopyTradeController`、`WFollowOrderViewController*`

## 分阶段交付（与 spec §8 对齐）

| Phase | 交付 | 验收 |
|-------|------|------|
| P2 | 合约页骨架 + meta | 切币对；列表 Mock/Test 可跑 |
| P3 | 下单 | `createOrder` + 确认弹窗 + 委托刷新 |
| P4 | 仓位/委托管理 | 撤单、平仓、改单主流程 |

## 验收清单

- [ ] 每个新 VC/Service 有 weexios 对照路径备注
- [ ] API path 与 `ApiConst.h` / `endpoints.md` 一致
- [ ] 无跟单 UI/API
- [ ] SnapKit 布局，无 SwiftUI
