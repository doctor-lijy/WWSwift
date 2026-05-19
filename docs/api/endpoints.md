# WWSwift API Endpoints

路径对照 weexios `WeexExchange/Common/Const/ApiConst.h`（新合约网关）。  
Base URL 由 `EnvironmentManager.contractAPIBaseURL` 提供，完整 URL = base + path。

## 环境 Base URL

| Environment | `currentEnv` | Base URL | 说明 |
|-------------|--------------|----------|------|
| Mock | `mock` | `https://mock.wwswift.local` | 本地 JSON / `MockProvider`，无真实网络 |
| Test (T3) | `test` | `https://http-gateway1.janapw.com` | 测试网关 |
| STG | `stg` | `https://http-gateway1.weex.com` | 预发 |
| Prod | `prod` | `https://http-gateway1.weex.com` | 生产 |

> 实现：`WWSwift/Core/Network/EnvironmentManager.swift`  
> weexios 对照：`DomainManager` / `AppENV_*` / `getRealUrl_New`

---

## Endpoint 表

| Key | Path | Purpose | Phase |
|-----|------|---------|-------|
| logout | `v1/user/login/logout` | 用户退出登录（POST） | P1 |
| meta | `api/v1/public/meta/getMetaDataNew` | 合约元数据（币对、精度等） | P2 |
| activeOrder | `api/v1/private/order/getActiveOrderPage` | 当前委托分页 | P2 |
| createOrder | `api/v1/private/order/createOrder` | 下单（限价/市价等） | P3 |
| cancelOrderById | `api/v1/private/order/cancelOrderById` | 按 ID 撤单 | P4 |
| closeAllPosition | `api/v1/private/order/closeAllPosition` | 一键平仓 / 全平 | P4 |

### weexios `ApiConst.h` 对照（节选）

| Key | 典型宏/常量名 | 备注 |
|-----|---------------|------|
| logout | `api_user_logout` 等 | 新网关 path 为 `v1/user/login/logout` |
| meta | `api_get_meta_data_new` | 公开接口，无需登录态（具体以网关为准） |
| activeOrder | `api_get_active_order_page` | 需私有鉴权 |
| createOrder | `api_create_order` | 需私有鉴权 |
| cancelOrderById | `api_cancel_order_by_id` | 需私有鉴权 |
| closeAllPosition | `api_close_all_position` | 需私有鉴权 |

---

## 维护约定

1. 新增或变更 path 时 **同时** 更新本表与 `.codex/skills/wwswift-env-and-api/SKILL.md` 中的列举（若属核心路径）。
2. Mock 响应文件命名建议：path 中 `/` 换为 `_`，如 `v1_user_login_logout.json`。
3. 禁止从 weexios 拷贝 `PHNet`；请求经 `APIClient` + `RequestSigning`（待实现）发出。
