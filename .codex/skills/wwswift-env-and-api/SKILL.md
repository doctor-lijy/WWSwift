---
name: wwswift-env-and-api
description: WWSwift 环境切换、contractAPIBaseURL、Mock 与 API endpoint 表维护。用于 EnvironmentManager、APIClient、Debug 环境页与网络层任务。
---

# 环境与 API

## 何时使用

- 修改 `EnvironmentManager`、`APIClient`、`MockProvider`
- 新增 HTTP path 或切换 mock/test/stg/prod

## 环境（`AppEnvironment`）

持久化键：`currentEnv`（`UserDefaults`）。

| Env | Base URL（新合约网关） |
|-----|------------------------|
| mock | `https://mock.wwswift.local` |
| test | `https://http-gateway1.janapw.com` |
| stg | `https://http-gateway1.weex.com` |
| prod | `https://http-gateway1.weex.com` |

实现见 `WWSwift/Core/Network/EnvironmentManager.swift` — 对齐 weexios `DomainManager.getRealUrl_New`。

## Mock 规则

- `mock`：`MockProvider` 按 path 匹配 `Resources/Mocks/*.json`
- `test`/`stg`/`prod`：真实 HTTPS；Debug 可注入 Token

## Endpoint 表

维护 **`docs/api/endpoints.md`**；新增 path 必须同步。对照 weexios `Common/Const/ApiConst.h`。

## 关键 endpoint（P0–P4）

见 `docs/api/endpoints.md` — logout、meta、activeOrder、createOrder、cancelOrderById、closeAllPosition。

## 验收

- [ ] `EnvironmentManagerTests` 通过
- [ ] Debug 页显示当前 baseURL 并可切换 env
- [ ] 文档与代码 base URL 一致
