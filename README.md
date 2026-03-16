# Santuan 三团 🐾

AI 驱动的桌面宠物 — 带情绪感知和性格进化。

## 项目架构

```
Santuan/
├── protocol/              # 跨语言 JSON Schema 协议
├── client/
│   ├── app/               # Flutter 主应用
│   └── packages/          # 解耦功能包
│       ├── platform_shell/      透明窗口 + 点击穿透
│       ├── pet_renderer/        可替换角色渲染
│       ├── animation_engine/    JSON 指令驱动动画
│       ├── emotion_bridge/      WebSocket / Mock 通信桥
│       └── ui_overlay/          对话气泡 / 右键菜单
├── services/              # Python AI 服务
│   ├── orchestrator/      WebSocket 编排器
│   ├── perception/        LibreFace 情绪识别
│   ├── emotion_cache/     EMA 平滑 + 偏移检测
│   ├── gemini_bridge/     Gemini 对话 + 长记忆
│   └── rl_trainer/        强化学习 / 性格进化
└── tools/                 # 构建脚本 / 代码生成
```

## 演进路线

| 阶段 | 目标 | 状态 |
|------|------|------|
| MVP  | 透明窗口 + Mock 动画切换 | 🔨 进行中 |
| V1.0 | 接入 LibreFace，"我笑它也笑" | ⏳ |
| V2.0 | 接入 Gemini，长记忆对话 | ⏳ |
| V3.0 | RL 性格进化 | ⏳ |

## 技术栈

- **客户端**: Flutter (Windows / macOS / Mobile)
- **AI 服务**: Python (LibreFace / Gemini / RL)
- **通信**: WebSocket (JSON)
- **渲染**: Rive (2.5D) / Thermion (3D) 可替换
- **状态管理**: flutter_riverpod
- **DI**: get_it

## 快速开始

```bash
# 客户端
cd client/app
flutter pub get
flutter run -d macos    # 或 -d windows

# AI 服务 (V1.0+)
cd services
pip install -r requirements.txt
python -m orchestrator.server
```

## License

MIT
