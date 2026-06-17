# rCodex Gateway macOS Homebrew 原生部署

## 适用场景

Homebrew 原生部署适合把 Mac 当作开发机使用的用户。Gateway 会直接运行在当前 macOS 用户环境中，可以访问真实项目路径、`~/.codex`、`~/.claude`，并调用 `xcodebuild`、`xcrun`、`security`、`pod`、`flutter` 等本机工具。

如果只是服务器或 NAS 常驻，仍建议使用 Docker 部署。

## 安装前确认

```bash
brew --version
node --version
codex --version
ls -la ~/.codex
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
```

如果 `~/.codex` 不存在，先在 Mac 终端完成 Codex CLI 登录。

## 安装方式

正式 tap 发布后：

```bash
brew tap rcodexlab/rcodex
brew install rcodex-gateway
```

配置文件默认位于：

```text
$(brew --prefix)/etc/rcodex-gateway/gateway.env
```

至少修改：

```bash
GATEWAY_ALLOWED_PATHS=/Users/your-user/Projects
GATEWAY_AUTH_USERNAME=your-name
GATEWAY_AUTH_PASSWORD=change-this-password
GATEWAY_AUTH_TOKEN=change-this-to-a-long-random-string
```

启动服务：

```bash
brew services start rcodex-gateway
curl http://127.0.0.1:8787/healthz
```

查看日志：

```bash
tail -f "$(brew --prefix)/var/log/rcodex-gateway.log"
```

## App 登录

查询 Mac 局域网 IP：

```bash
ipconfig getifaddr en0
```

App 登录页填写：

```text
http://<Mac局域网IP>:8787
```

账号和密码使用 `gateway.env` 中的 `GATEWAY_AUTH_USERNAME` 与 `GATEWAY_AUTH_PASSWORD`。

## 与 Docker 的差异

- Homebrew 使用真实 macOS 路径，例如 `/Users/your-user/Projects`。
- Docker 通常使用容器路径，例如 `/workspace`。
- Homebrew 可以直接调用 Xcode、Keychain、模拟器和真机相关命令。
- Homebrew 服务运行在用户系统环境，敏感凭据仍应只保存在用户目录或系统凭据中。

