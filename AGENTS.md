# AGENTS.md — WWSwift

本仓库为 **独立 Swift 工程**，与 weexios **原则零源码依赖**。`PHNet.xcframework` 视为公司内部已编译 SDK，例外允许以二进制方式纳入。weexios 其余部分仅作只读对照。

**本机路径：** `/Users/lijingyi/Desktop/WW/AITest/WWSwift`（与 [设计 spec](docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md) 一致；勿在 `WW/WWSwift` 另建副本）

## 必读文档

- 设计 spec：[`docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md`](docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md)
- weexios 模块映射：[`docs/reference/weexios-mapping.md`](docs/reference/weexios-mapping.md)

## 提交约定

- **所有 WWSwift 相关改动只提交本仓库**（`doctor-lijy/WWSwift`）
- **不要在 weexios 仓库** 添加 WWSwift 实现、spec 或 Pod 依赖

## 技术约束

- UIKit + SnapKit；**禁止 SwiftUI**
- 网络层：以 `PHNet.xcframework`（内部二进制 SDK，置于 `WWSwift/Vendor/`）+ `AFNetworking` Pod 为底座；**禁止**引入其他 weexios 源码或 framework
- 合约模块排除跟单：`WContractCopyTradeController`、`CopyTrade/**`、`WFollowOrderViewController*`
- 本工程**不上线**，仅用于对照学习与 Swift 重写

## 模块 Skills（P0 起逐步添加）

| 场景 | 路径 |
|------|------|
| 合约 OC→Swift | `.codex/skills/wwswift-oc-to-swift-contract/` |
| 退出登录 | `.codex/skills/wwswift-logout-flow/` |
| 环境与 API | `.codex/skills/wwswift-env-and-api/` |

## 对照 weexios 时的路径

| WWSwift 能力 | weexios 参考路径 |
|--------------|------------------|
| 合约 UI | `WeexExchange/WeexExchange/UI/Main/Trade/Contract/` |
| 退出登录 | `Manager/Login/WLoginManager.m`、`Login/LoginHandler.m`、`Manager/User/UserManger.m` |
| API 常量 | `Common/Const/ApiConst.h` |
| 环境切换 | `DomainManager`、`AppDelegate+Service.m`（`currentEnv`） |
