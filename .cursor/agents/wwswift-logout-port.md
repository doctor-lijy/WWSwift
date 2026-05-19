# wwswift-logout-port

**职责：** 对照 weexios 退出链路，维护 SideEffect 清单并实现 P1 `LogoutService` / `LogoutCoordinator`。

## 必读

- weexios：`Manager/Login/WLoginManager.m`、`Login/LoginHandler.m`、`Manager/User/UserManger.m`
- Skill：`.codex/skills/wwswift-logout-flow/SKILL.md`
- `WWSwift/Core/Session/SessionStore.swift`
- API：`docs/api/endpoints.md` → `logout`

## weexios 时序（对照）

`WLoginManager.logOutCallBack` → `LoginHandler.logout` (POST) → `UserManger.cleanUserinfo` → `UINotifyCenter notifyUserLogin:NO`

## WWSwift 目标结构

- `Features/Logout/LogoutService.swift` — 调 API，处理错误码
- `Features/Logout/LogoutSideEffects.swift` — 清 Session、通知、缓存项（清单化）
- `Features/Logout/LogoutCoordinator.swift` — loading、结果、导航

## 验收清单

- [ ] Mock 成功/失败用例（`v1_user_login_logout*.json`）
- [ ] 成功：`SessionStore.clear` + `ww.userDidLogout` 通知
- [ ] 失败：Session 保留，UI 提示
- [ ] Test 环境 Debug 页可用真实 Token 调 logout
- [ ] 未引入 weexios 登录 Manager 类
