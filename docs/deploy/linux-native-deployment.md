# rCodex Gateway Linux 原生部署

## 适用场景

Linux 原生部署适合 Ubuntu / Debian 系个人开发机或长期在线主机。Gateway 直接运行在宿主机环境中，可以访问真实用户目录、Codex / Claude 登录态、SSH key、Git 凭据和本机工具链。

后续推荐部署路径：

- 个人开发机：优先原生部署。
- Linux 服务器：优先原生部署。
- NAS、强隔离、企业镜像分发：保留 Docker。

## 安装前确认

```bash
node --version
codex --version
git --version
ls -la ~/.codex
```

如果使用 Claude Code：

```bash
claude --version
ls -la ~/.claude
```

如果 `~/.codex` 不存在，先在当前 Linux 用户下完成 Codex CLI 登录。

## 安装方式

GitHub Releases 发布后可以使用：

```bash
curl -fsSL https://github.com/rcodexlab/rcodex-releases/releases/latest/download/install-gateway-linux.sh | sudo bash
```

或指定版本和架构：

```bash
curl -fsSL https://github.com/rcodexlab/rcodex-releases/releases/download/v1.2.58/install-gateway-linux.sh \
  | sudo VERSION=1.2.58 ARCH=x64 bash
```

默认路径：

```text
/opt/rcodex/gateway
/etc/rcodex/gateway.env
/var/lib/rcodex/gateway
/var/log/rcodex/gateway
/etc/systemd/system/rcodex-gateway.service
```

## 配置

编辑：

```bash
sudo nano /etc/rcodex/gateway.env
```

至少修改：

```bash
GATEWAY_ALLOWED_PATHS=/home/your-user/Projects
GATEWAY_AUTH_USERNAME=your-name
GATEWAY_AUTH_PASSWORD=change-this-password
GATEWAY_AUTH_TOKEN=change-this-to-a-long-random-string
```

如果 Gateway 需要读取当前用户的 Codex 登录态，建议把 systemd 服务里的 `User=` 改成该用户，或者把登录态迁移到服务用户目录。个人开发机优先使用真实登录用户运行服务。

## 启动与检查

```bash
sudo systemctl enable --now rcodex-gateway
sudo systemctl status rcodex-gateway
curl http://127.0.0.1:8787/healthz
```

查看日志：

```bash
sudo journalctl -u rcodex-gateway -f
sudo tail -f /var/log/rcodex/gateway/gateway.log
```

## App 登录

查询局域网 IP：

```bash
hostname -I
```

App 登录页填写：

```text
http://<Linux局域网IP>:8787
```

账号和密码使用 `/etc/rcodex/gateway.env` 中的 `GATEWAY_AUTH_USERNAME` 与 `GATEWAY_AUTH_PASSWORD`。

## 与 Docker 的差异

- 原生部署使用真实 Linux 路径，例如 `/home/your-user/Projects`。
- Docker 通常使用容器路径，例如 `/workspace`。
- 原生部署可以直接使用宿主机 SSH key、Git 凭据和开发工具链。
- 原生部署权限由 systemd 运行用户和 `GATEWAY_ALLOWED_PATHS` 共同控制。

