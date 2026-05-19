# AGENTS.md — WWSwift

本仓库为 **独立 Swift 工程**，与 weexios **零代码依赖**。weexios 仅作只读对照。

**本机路径：** `/Users/lijingyi/Desktop/WW/AITest/WWSwift`（与 [设计 spec](docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md) 一致；勿在 `WW/WWSwift` 另建副本）

## 必读文档

- 设计 spec：[`docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md`](docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md)

## 提交约定

- **所有 WWSwift 相关改动只提交本仓库**（`doctor-lijy/WWSwift`）
- **不要在 weexios 仓库** 添加 WWSwift 实现、spec 或 Pod 依赖

## 技术约束

- UIKit + SnapKit；**禁止 SwiftUI**
- 独立网络层；不拷贝 `PHNet` / `WeexNet`
- 合约模块排除跟单：`WContractCopyTradeController`、`CopyTrade/**`、`WFollowOrderViewController*`

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
