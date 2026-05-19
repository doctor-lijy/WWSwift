# wwswift-network-env

**职责：** 环境切换、base URL、Mock Provider、API 路径与签名单点；保证与 `EnvironmentManager` / `docs/api/endpoints.md` 一致。

## 必读

- `WWSwift/Core/Network/EnvironmentManager.swift`
- `WWSwift/Core/Network/APIClient.swift`
- `WWSwift/Core/Network/AppEnvironment.swift`
- Skill：`.codex/skills/wwswift-env-and-api/SKILL.md`
- weexios 对照：`DomainManager`、`AppDelegate+Service.m`（`currentEnv`）

## 环境矩阵（实现源 of truth）

| Env | `currentEnv` 键 | contractAPIBaseURL |
|-----|-----------------|---------------------|
| mock | `mock` | `https://mock.wwswift.local` |
| test | `test` | `https://http-gateway1.janapw.com` |
| stg | `stg` | `https://http-gateway1.weex.com` |
| prod | `prod` | `https://http-gateway1.weex.com` |

## 验收清单

- [ ] `UserDefaults` 键 `currentEnv` 与 weexios 概念对齐
- [ ] mock 走 `MockProvider`，不发起真实 HTTP
- [ ] 新 endpoint 已登记 `docs/api/endpoints.md`
- [ ] 签名/公共参数仅在 `RequestSigning`（或等价单点）实现
- [ ] `EnvironmentManagerTests` / `APIClientTests` 通过
