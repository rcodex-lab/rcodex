# rCodex Gateway Homebrew Preview

本目录保存 macOS Homebrew 原生部署的 Formula 模板和说明。

正式对外使用时，`Formula/rcodex-gateway.rb` 应同步到公开 tap 仓库，例如：

```text
github.com/rcodexlab/homebrew-rcodex
```

用户侧目标体验：

```bash
brew tap rcodexlab/rcodex
brew install rcodex-gateway
brew services start rcodex-gateway
curl http://127.0.0.1:8787/healthz
```

当前目录为 Preview 支持文件，发布前需要把 Formula 中的下载地址和 SHA256 更新为实际 GitHub Release 资产。

