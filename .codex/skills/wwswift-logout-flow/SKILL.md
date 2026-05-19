---
name: wwswift-logout-flow
description: 实现与验收 WWSwift 退出登录：API、Session 清理、SideEffect、通知与 Coordinator。用于 Logout、Session、登录态相关任务。
---

# 退出登录链路

## 何时使用

- `Features/Logout/**`、`SessionStore`、Debug 页「触发退出登录」
- 对照 weexios 退出行为

## weexios 对照

| 步骤 | 文件 |
|------|------|
| 入口回调 | `Manager/Login/WLoginManager.m` |
| HTTP 退出 | `Login/LoginHandler.m` → POST logout |
| 清用户信息 | `Manager/User/UserManger.m` → `cleanUserinfo` |
| 通知 | `UINotifyCenter` → `notifyUserLogin:NO` |

## API

- **Path:** `v1/user/login/logout`（POST，body 可为空字典）
- **Mock:** `WWSwift/Resources/Mocks/v1_user_login_logout.json`
- **失败 Mock:** `v1_user_login_logout_fail.json`（P1 Task 8）

## WWSwift 实现顺序

1. `LogoutService` — `apiClient.post` + 解析 `LogoutResponseDTO`
2. 成功 → `SessionStore.clear()` → `LogoutSideEffectRegistry.performAfterLogout()`
3. 发 `Notification.Name.wwUserDidLogout`
4. `LogoutCoordinator` — UI loading / 错误提示 / 回未登录态

## 验收

- [ ] Mock 成功：Session 空、通知已发
- [ ] Mock 失败：Session 保留
- [ ] Test 环境：Debug 注入 Token 可调真实 API
