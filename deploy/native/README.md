# rCodex Gateway 原生部署分发说明

本目录用于约束 macOS Homebrew、Windows 原生安装包与 Linux systemd 原生安装包的共同分发规则。

原生部署面向个人开发机和常规 Linux 主机，目标是让 Gateway 直接运行在用户系统里，便于读取本机 Codex / Claude 登录态，并调用 Xcode、Visual Studio、Flutter、Android SDK、SSH、Git 等本机工具链。Docker 后续保留给 NAS、强隔离、企业镜像分发和离线容器场景。

## 分发边界

- 主仓库保存打包脚本、部署模板和文档。
- Homebrew tap 仓库只保存 `Formula/rcodex-gateway.rb`。
- GitHub Releases 保存裁剪后的安装包。
- 原生安装包只包含运行所需文件，不包含 TypeScript 源码、测试、内部计划文档、密钥或 Git 元数据。

## 发布包内容

允许包含：

- `dist/`
- `package.json`
- `package-lock.json`
- `deploy/version/`
- `bin/`
- `etc/`

禁止包含：

- `src/`
- `*.ts`
- `*.test.*`
- `.env`
- `.git/`
- `docs/plans/`
- 内部调试脚本或临时文件

发布前必须运行：

```bash
./scripts/verify_gateway_native_package.sh <package>
```

## GitHub Releases 资产命名

建议每个版本同时发布：

```text
rcodex-gateway-<version>-linux-x64.tar.gz
rcodex-gateway-<version>-linux-arm64.tar.gz
rcodex-gateway-<version>-darwin-arm64.tar.gz
rcodex-gateway-<version>-darwin-x64.tar.gz
rcodex-gateway-<version>-windows-x64.zip
install-gateway-linux.sh
checksums.txt
```

Homebrew Formula、Linux 安装脚本和 Windows 安装脚本都只引用 GitHub Release URL 与 SHA256，不把二进制发布包提交到 Git 仓库。
