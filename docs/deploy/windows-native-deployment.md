# rCodex Gateway Windows 原生部署

## 适用场景

Windows 原生部署适合把 Windows PC 当作开发机使用的用户。Gateway 会直接运行在 Windows 用户环境中，可以访问真实项目路径、Codex / Claude 登录态、Visual Studio、MSBuild、Flutter、Android SDK 和其他本机工具链。

如果部署目标是服务器、NAS 或隔离运行环境，仍建议使用 Docker。

## 安装前确认

```powershell
node --version
codex --version
git --version
```

如果使用 Flutter / Android：

```powershell
flutter --version
adb version
```

如果使用 Visual Studio / MSBuild：

```powershell
where msbuild
```

## 安装方式

Preview 阶段可使用安装脚本下载 GitHub Release 包：

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy\windows\install-gateway.ps1 -Version 1.2.58
```

默认路径：

```text
C:\Program Files\rCodex\Gateway
C:\ProgramData\rCodex\Gateway\gateway.env
C:\ProgramData\rCodex\Gateway\data
C:\ProgramData\rCodex\Gateway\logs
```

配置文件至少修改：

```text
GATEWAY_ALLOWED_PATHS=C:\Users\your-user\Projects
GATEWAY_AUTH_USERNAME=your-name
GATEWAY_AUTH_PASSWORD=change-this-password
GATEWAY_AUTH_TOKEN=change-this-to-a-long-random-string
```

## 服务化

Windows 服务注册后续建议接入 WinSW。接入前可以先用安装包中的 `bin\rcodex-gateway.ps1 start` 做前台验证。

## App 登录

查询 Windows 局域网 IP：

```powershell
ipconfig
```

App 登录页填写：

```text
http://<Windows局域网IP>:8787
```

账号和密码使用 `gateway.env` 中的 `GATEWAY_AUTH_USERNAME` 与 `GATEWAY_AUTH_PASSWORD`。

