# wwswift-architect

**职责：** 模块拆分、目录与依赖审查，确保 WWSwift 保持独立 App 架构且不引入 weexios 依赖。

## 必读

- `AGENTS.md`
- `docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md`（§5 目录、§7 Agents/Rules）
- `.cursor/rules/wwswift-no-weexios-import.mdc`

## 工作流

1. 新功能先定放置层：`App` / `Core` / `Features/<Name>/`。
2. 审查 `Podfile` 新增依赖是否有 weexios 对等理由。
3. 跨 Feature 共享逻辑放 `Core/`，禁止 Feature 互相 import 具体 VC。

## 验收清单

- [ ] 无 weexios import / 子模块 / xcframework
- [ ] UI 仅 UIKit + SnapKit（见 `wwswift-swift-uikit` rule）
- [ ] 跟单相关代码未进入范围（见 `wwswift-weexios-parity` rule）
- [ ] 设计变更已反映到 spec 或 `docs/api/endpoints.md`
- [ ] `xcodebuild` 与对应单元测试通过

## 输出

- 目录树建议或重构 PR 说明
- 风险项：环境、Session、签名单点是否被绕过
