# WWSwift

WEEX iOS 合约与退出登录能力的 **独立 Swift 复刻工程**（UIKit，非 SwiftUI）。

- **设计说明：** [docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md](docs/superpowers/specs/2026-05-19-wwswift-standalone-design.md)
- **对照参考：** [weexios](https://github.com/doctor-lijy?tab=repositories) 本地 `WeexExchange`（只读，不提交联动改动）
- **仓库：** https://github.com/doctor-lijy/WWSwift

## 要求

- iOS 14.0+
- Swift 5.0+
- UIKit + SnapKit（禁止 SwiftUI）

## 范围

| 包含 | 不包含 |
|------|--------|
| 合约交易（骨架 + 下单 + 仓位/委托管理） | 跟单 / `WContractCopyTradeController` |
| 退出登录链路 | 完整注册/登录 UI |
| Mock ⇄ Test/Stg/Prod 环境切换 | 与 weexios 混编或 Pod 集成 |

## 开发约定

- **所有设计与实现仅提交本仓库**
- weexios 仅用于对照 API、交互与目录结构
- 实施阶段见设计文档 §8（P0–P5）

## 目录结构（目标）

```
WWSwift/
├── WWSwift/                 # App 源码（P0 起逐步落地）
├── docs/
│   └── superpowers/specs/ # 设计文档
├── .cursor/                 # Rules / Agents
├── .codex/skills/           # 迁移技能
├── Podfile
├── AGENTS.md
└── README.md
```

> 当前仓库仍为早期脚手架（`SourceCode/` + `WWSwift.podspec`），P0 将替换为独立 Xcode App 工程。

## License

MIT
