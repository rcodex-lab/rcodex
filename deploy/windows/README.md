# rCodex Gateway Windows 原生部署 Preview

本目录保存 Windows 原生部署模板。

Windows 原生部署适合个人开发机，可直接访问真实项目路径、用户目录、Codex / Claude 登录态以及 Visual Studio、MSBuild、Flutter、Android SDK 等本机工具链。服务器和 NAS 部署仍优先使用 Docker。

## 目标体验

```powershell
.\install-gateway.ps1 -Version 1.2.58
rcodex-gateway service start
curl http://127.0.0.1:8787/healthz
```

## 默认路径

- 安装目录：`C:\Program Files\rCodex\Gateway`
- 配置文件：`C:\ProgramData\rCodex\Gateway\gateway.env`
- 数据目录：`C:\ProgramData\rCodex\Gateway\data`
- 日志目录：`C:\ProgramData\rCodex\Gateway\logs`

## 发布说明

发布包应来自 `scripts/package_gateway_windows.ps1`，并经过 `scripts/verify_gateway_native_package.sh` 校验，确保不包含源码、测试、`.env`、`.git` 和内部计划文档。

