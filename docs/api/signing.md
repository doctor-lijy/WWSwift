# HTTP / Socket 签名（WWSwift）

WWSwift **不在 Swift 中复刻** weexios `RequestMap` HMAC。签名由 **PHNet** 承担：

| 层 | 类 | 职责 |
|----|-----|------|
| HTTP header | `WeexHttpClient.configHeader` | 由 `PHNetBootstrap.buildHTTPHeader` 注入 u-token、X-SIG、sidecar 等 |
| Socket header | `RuntimeAPPEnv.socketHeader` | `PHNetBootstrap.buildSocketHeader` |
| sidecar | `SecurityManager.getSideCarSign` | PHNet 内部 |

## 调用路径

- **Test / STG / Prod：** 业务代码统一经 `APIClient.post(path:body:)` → `WeexHttpClient.postJson`；header 与 sidecar 由 PHNet 在请求发出前注入。
- **Mock：** `EnvironmentManager.current == .mock` 时走 `MockProvider` 本地 JSON，**不经过** PHNet。

## 实现位置

| 文件 | 说明 |
|------|------|
| `WWSwift/Core/Network/PHNetBootstrap.swift` | 启动期配置 `RuntimeAPPEnv`、`WeexHttpClient.configHeader`、域名切换 |
| `WWSwift/Core/Network/APIClient.swift` | 门面；非 Mock 环境委托 PHNet |
| `WWSwift/Core/Session/SessionStore.swift` | `accessToken` / `userToken` / `rToken` 供 header 读取 |

## weexios 对照

| weexios | WWSwift |
|---------|---------|
| `RequestMap` + HMAC | PHNet `SecurityManager` + `PHNetBootstrap` header 块 |
| `WeexNet.m` 初始化 | `PHNetBootstrap.configure` + `AppDelegate` |

## 维护约定

1. 不要新增 `RequestSigning.swift` 或在 Swift 中重复实现 X-SIG / sidecar。
2. 若 header 字段变更，只改 `PHNetBootstrap` 并对照 weexios `WeexNet.m` / `WeexHttpClient` 行为。
3. 签名说明变更时同步更新 `docs/api/endpoints.md` 维护约定第 3 条。
