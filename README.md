# 小学生英语语法测验

一个面向中文使用场景的英语语法练习项目，支持 Web 使用，也支持封装成 Windows 桌面应用。

它适合这些场景：

- 快速搭建一个可用的英语语法练习站
- 把真题中的选择题、填空题整理成可练习题库
- 保留“题目 + 答案 + 考点 + 讲解”的完整结构
- 持续扩展题库和知识点，而不是把内容写死在页面里

## 项目亮点

- 支持选择题、填空题两种核心题型
- 支持随机练习、按考点练习
- 支持自定义每轮练习题数
- 每题提交后立即反馈对错、正确答案、考点和讲解
- 结果汇总展示整轮错题
- 内置错题再练模块
- 题库、知识点、作答记录分离存储
- 支持后续持续扩库和导题

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 启动 Web 开发模式

```bash
npm run dev
```
你可以选择以下任意一种方式：

**方式一：双击批处理文件（推荐）**

直接双击项目根目录下的 start-dev-env.bat，它会自动：
1. 启动 
pm run dev（新窗口）
2. 等待开发服务器就绪
3. 启动 Cloudflare Tunnel 并自动抓取公网 URL
4. 在绿色大字中显示公网地址，手机 5G 也可访问

**方式二：终端命令**

启动后访问：

- 前端：`http://localhost:4175`
- 后端：`http://localhost:4310`

### AI 解析接入

当前版本已经支持在提交答案后调用 AI 生成更深入的中文讲解；如果未配置或调用失败，会自动回退到题库里的基础讲解。

推荐先复制一份模板：

```powershell
Copy-Item .env.example .env
```

先在启动前配置环境变量：

```powershell
$env:AI_EXPLANATION_ENABLED="true"
$env:OPENAI_API_KEY="你的 API Key"
$env:OPENAI_MODEL="gpt-4.1-mini"
```

可选项：

```powershell
$env:OPENAI_BASE_URL="https://api.openai.com/v1"
```

说明：

- `AI_EXPLANATION_ENABLED=true` 才会真正发起 AI 解析请求
- `OPENAI_API_KEY` 未设置时，系统会继续使用原有固定讲解
- `OPENAI_BASE_URL` 可用于兼容 OpenAI 接口的代理或网关
- 相同题目、相同学生答案、相同对错状态会命中本地缓存，减少重复请求
- AI 解析缓存文件默认保存在 `data/ai-explanations-cache.json`

### 国产大模型支持

当前版本已经内置常见 OpenAI 兼容接口的自动识别。多数情况下，用户只需要在 `.env` 里填写某一家厂商的 `API_KEY`，系统就会自动选好默认 `baseUrl` 和 `model`。

已内置：

- `DEEPSEEK_API_KEY`：默认 `https://api.deepseek.com/v1` + `deepseek-chat`
- `DASHSCOPE_API_KEY`：默认 `https://dashscope.aliyuncs.com/compatible-mode/v1` + `qwen-plus`
- `ZHIPU_API_KEY`：默认 `https://open.bigmodel.cn/api/paas/v4` + `glm-4-flash`
- `MOONSHOT_API_KEY`：默认 `https://api.moonshot.cn/v1` + `moonshot-v1-8k`

如果同时填写了多家，当前优先级为：

1. `DEEPSEEK_API_KEY`
2. `DASHSCOPE_API_KEY`
3. `ZHIPU_API_KEY`
4. `MOONSHOT_API_KEY`
5. `OPENAI_API_KEY`

如果你想改默认模型，也可以只改对应厂商的 `*_MODEL`，不需要手动改代码。

### 3. 运行测试

```bash
npm test
```

### 4. 构建生产版本

```bash
npm run build
```

## 通过 Cloudflare Tunnel 临时分享访问

如果同一局域网内的其他设备无法直接访问你的本机开发环境，可以使用 Cloudflare Tunnel 生成一个临时公网链接。项目提供了两个批处理脚本方便使用。

### 快速启动

**start-tunnel.bat**：单独启动 Tunnel（需要先手动运行 
pm run dev）

**start-dev-env.bat**：一键启动，自动运行 dev server + Tunnel + 自动捕获 URL（推荐）

### 前提条件

需要先安装 cloudflared：

`powershell
winget install Cloudflare.cloudflared
`

### 手动命令（用于参考）

`powershell
cloudflared tunnel --url http://localhost:4175
`

如果终端提示 cloudflared 不是内部或外部命令，请使用 cloudflared 的完整路径：

`powershell
& "C:\Users\NuoHe\AppData\Local\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe" tunnel --url http://localhost:4175
`

### 常见问题

如果 Tunnel 连接不稳定（国内网络到 Cloudflare 边缘节点可能受限），可以尝试：

- 关闭 VPN 后重试
- 多次运行直到连接成功（监控脚本内置了 60 秒等待和自动重试提示）
- 使用 
grok 作为替代：
px ngrok http 4175

### 工作原理

start-dev-env.bat 的详细流程：

1. 启动 
pm run dev（新窗口）
2. 轮询检测 port 4175 是否就绪
3. 调用 scripts/monitor-tunnel.ps1
4. 脚本启动 cloudflared 并写日志
5. 监控日志直到出现 https://*.trycloudflare.com URL
6. 继续等待 "Registered tunnel connection" 确认连接稳定
7. 绿色大字显示公网 URL

每个 Quick Tunnel URL 都是临时且唯一的，关闭后重新运行会生成新的 URL。如需固定域名请改用 Cloudflare Named Tunnel + 自有域名。

### 连接注意

- 如果页面提示 host is not allowed，请确认 ite.config.ts 中已允许 *.trycloudflare.com
- 关闭 
pm run dev 或 cloudflared 后，临时外链会失效
- Quick Tunnel 适合演示或测试，不适合长期生产使用
- 如需固定域名，请改用 Cloudflare Named Tunnel 或正式部署
## Dev Environment Launcher（开发环境启动器）

项目根目录提供了两个批处理脚本，双击即可使用：

| 脚本 | 功能 |
| --- | --- |
| start-dev-env.bat | **一键启动**：自动运行 
pm run dev + Cloudflare Tunnel，自动捕获并显示公网 URL |
| start-tunnel.bat | **单独启动 Tunnel**：当 dev server 已运行时，单独开启 Cloudflare Tunnel |

配套脚本：

| 脚本 | 功能 |
| --- | --- |
| scripts/monitor-tunnel.ps1 | 核心监控脚本：启动 Tunnel、监控日志、等待连接稳定、显示 URL |

---
## 桌面版支持

如果你想把它作为本地应用来使用，可以直接运行桌面开发模式：

```bash
npm run dev:desktop
```

如果要打包 Windows 安装包：

```bash
npm run build:desktop
```

## 适合怎么用

### 作为练习站

直接使用现有题库，给学生做日常英语语法练习。

### 作为题库整理底座

把 Word/PDF 真题先整理成文本、表格或中间 JSON，再导入系统题库。

### 作为二次开发项目

你可以在这个基础上继续增加：

- 登录系统
- 学生记录
- 错题本
- 知识点管理后台
- 更复杂的判题规则
- 在线部署版本

## 当前功能

- 随机练习
- 按考点练习
- 选择题练习
- 填空题练习
- 自定义练习题数
- 每题即时反馈
- 结果汇总
- 错题再练
- 本地作答记录保存
- 本地 JSON 题库和知识点读取
- Electron 桌面壳

## 技术栈

- 前端：React 18 + TypeScript + Vite
- 后端：Express + TypeScript
- 桌面封装：Electron
- 数据校验：Zod
- 测试：Vitest
- 存储：本地 JSON 文件

## 本地运行

### 环境要求

- Windows
- Node.js 18 或更高
- npm 9 或更高

检查版本：

```bash
node -v
npm -v
```

### 安装依赖

```bash
npm install
```

### 启动 Web 开发模式

```bash
npm run dev
```

默认地址：

- 前端：`http://localhost:4175`
- 后端：`http://localhost:4310`

### 启动桌面开发模式

```bash
npm run dev:desktop
```

这个命令会同时启动：

- Express 后端
- Vite 前端
- Electron 桌面窗口

### 构建 Web 版本

```bash
npm run build
```

输出目录：

- 前端静态文件：`dist/`
- 后端构建文件：`dist/server/`

### 启动生产服务

```bash
npm run start
```

### 构建 Windows 安装包

```bash
npm run build:desktop
```

默认输出目录：

- `release/`

### 运行测试

```bash
npm test
```

## 常用脚本

| 命令 | 说明 |
| --- | --- |
| `npm run dev` | 启动 Web 开发模式 |
| `npm run dev:server` | 单独启动后端 |
| `npm run dev:client` | 单独启动前端 |
| `npm run dev:desktop` | 启动桌面开发模式 |
| `npm run build` | 构建 Web 版本 |
| `npm run build:electron` | 构建 Electron 代码 |
| `npm run build:desktop` | 构建桌面安装包 |
| `npm run start` | 启动生产后端 |
| `npm run start:desktop` | 启动本地桌面应用 |
| `npm test` | 运行测试 |
| start-dev-env.bat | **(双击)** 一键启动开发环境 + Tunnel 公网分享 |
| start-tunnel.bat | **(双击)** 单独启动 Cloudflare Tunnel |

## 项目结构

```text
primary-english-grammar-quiz/
|-- data/
|   |-- attempts.json
|   |-- import-template.json
|   |-- knowledge-points.json
|   `-- questions.json
|-- question-bank/
|   |-- answers-text/
|   |-- images/
|   |-- json/
|   |-- manual/
|   |-- parsed/
|   |-- questions-text/
|   `-- raw-exams/
|-- scripts/
|-- src/
|   |-- client/
|   |-- electron/
|   `-- server/
|-- package.json
|-- tsconfig.server.json
|-- tsconfig.electron.json
`-- vite.config.ts
```

## 数据说明

### `data/questions.json`

运行时题库文件，前后端练习流程直接读取这里的数据。

主要字段：

- `id`
- `sourceType`
- `stem`
- `options`
- `answer`
- `gradeBand`
- `examSource`
- `knowledgePointId`
- `explanation`
- `difficulty`

### `data/knowledge-points.json`

运行时知识点文件。

主要字段：

- `id`
- `name`
- `category`
- `description`
- `keywords`
- `relatedPoints`

### `data/attempts.json`

本地作答记录文件。每次提交答案后会追加记录。

### `data/import-template.json`

后续人工整理 Word/PDF 题目时使用的导入模板。

## 题库工作区

`question-bank/` 是题库整理工作区，不是前端运行时直接读取的目录。

主要用途：

- `raw-exams/`：原始试卷文件
- `parsed/`：原始文件转出的中间文本
- `questions-text/`：拆分后的题目文本
- `answers-text/`：拆分后的答案文本
- `manual/`：人工补录和纠偏数据
- `json/`：可导入系统的结构化产物
- `images/`：无法直接抽文本时的辅助图片

## 导题与扩库流程

推荐流程：

1. 把新的 Word/PDF 原始题放进 `question-bank/raw-exams/`
2. 先整理出题目文本和答案文本
3. 如果自动抽取不稳定，在 `question-bank/manual/` 里补录
4. 运行题库处理脚本
5. 生成新的结构化 JSON
6. 校验后同步到 `data/questions.json` 和 `data/knowledge-points.json`

相关脚本：

- `node scripts/process-question-bank.mjs`
- `node scripts/generate-manual-overrides.mjs`
- `node scripts/generate-legacy-overrides.mjs`
- `node scripts/enrich-knowledge-points.mjs`

## 练习规则

### 选择题

- 按正确选项文本判定
- 兼容题库里使用 `A/B/C/D` 存储答案的情况

### 填空题

- 忽略首尾空格
- 忽略大小写

## 开源协议

本项目基于 [MIT License](./LICENSE) 开源。

## 仓库地址

- GitHub: `https://github.com/jjy1213/primary-english-grammar-quiz`
