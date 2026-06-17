# rCodex Gateway Linux 原生部署 Preview

本目录保存 Ubuntu / Debian 系 Linux 原生部署模板。

Linux 原生部署适合个人开发机或长期在线的 Linux 主机。Gateway 直接运行在宿主机用户态，可读取真实 `~/.codex`、`~/.claude`、SSH key、Git 凭据和项目路径，也能调用宿主机安装的 Node、Python、Go、Rust、Java、Flutter、Android SDK 等工具链。

Docker 后续保留给 NAS、隔离运行、企业镜像分发和离线容器场景。

## 目标体验

```bash
curl -fsSL https://github.com/rcodexlab/rcodex-releases/releases/latest/download/install-gateway-linux.sh | bash
sudo systemctl enable --now rcodex-gateway
curl http://127.0.0.1:8787/healthz
```

## 默认路径

- 程序目录：`/opt/rcodex/gateway`
- 配置文件：`/etc/rcodex/gateway.env`
- 数据目录：`/var/lib/rcodex/gateway`
- 日志目录：`/var/log/rcodex/gateway`
- systemd 服务：`/etc/systemd/system/rcodex-gateway.service`

## 发布说明

发布包应来自 `scripts/package_gateway_linux.sh`，并经过 `scripts/verify_gateway_native_package.sh` 校验，确保不包含源码、测试、`.env`、`.git` 和内部计划文档。

