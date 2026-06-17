# Gateway npm 安装部署

Gateway 默认采用 npm CLI 分发，不再要求用户下载平台专属运行包或安装 exe。

## 安装

先安装 Node.js 22 或更高版本，然后执行：

```bash
npm install -g @rcodex/gateway
rcodex-gateway setup
rcodex-gateway start
```

`setup` 会在本机创建 `gateway.env` 和数据目录，并生成随机的管理员密码和访问 token。默认配置路径：

- Windows：`C:\ProgramData\rCodex\Gateway\gateway.env`
- macOS / Linux：`~/.rcodex/gateway/gateway.env`

## 发版

Gateway 发版使用：

```bash
pwsh -ExecutionPolicy Bypass -File .\scripts\package_gateway_npm.ps1
```

需要正式发布 npm 时：

```bash
pwsh -ExecutionPolicy Bypass -File .\scripts\package_gateway_npm.ps1 -Publish
```

Linux / Ubuntu 发布机可使用：

```bash
./scripts/package_gateway_npm.sh --publish
```

发布前脚本会重新构建 Gateway、执行 `npm pack`，并扫描 npm 包内容。包内只能包含 `dist/`、`package.json`、`README.md` 等运行必需内容，不得包含源码、测试、`.env`、内部文档或 Git 元数据。
