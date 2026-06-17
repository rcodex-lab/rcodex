#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-1.2.58}"
ARCH="${ARCH:-x64}"
RELEASE_BASE_URL="${RELEASE_BASE_URL:-https://github.com/rcodexlab/rcodex-releases/releases/download}"
INSTALL_DIR="${INSTALL_DIR:-/opt/rcodex/gateway}"
CONFIG_DIR="${CONFIG_DIR:-/etc/rcodex}"
DATA_DIR="${DATA_DIR:-/var/lib/rcodex/gateway}"
LOG_DIR="${LOG_DIR:-/var/log/rcodex/gateway}"
SERVICE_USER="${SERVICE_USER:-rcodex}"
PACKAGE_NAME="rcodex-gateway-${VERSION}-linux-${ARCH}.tar.gz"
PACKAGE_URL="${RELEASE_BASE_URL}/v${VERSION}/${PACKAGE_NAME}"

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 或 sudo 执行安装脚本。" >&2
    exit 1
  fi
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "未找到命令: $1" >&2
    exit 1
  fi
}

ensure_user() {
  if id "$SERVICE_USER" >/dev/null 2>&1; then
    return 0
  fi

  useradd --system --create-home --home-dir "/home/${SERVICE_USER}" --shell /usr/sbin/nologin "$SERVICE_USER"
}

download_package() {
  local target="$1"

  if command -v curl >/dev/null 2>&1; then
    curl -fL "$PACKAGE_URL" -o "$target"
    return 0
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -O "$target" "$PACKAGE_URL"
    return 0
  fi

  echo "未找到 curl 或 wget。" >&2
  exit 1
}

main() {
  require_root
  require_command node
  require_command tar
  require_command systemctl
  ensure_user

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  local package_path="$tmp_dir/$PACKAGE_NAME"
  echo "下载 $PACKAGE_URL"
  download_package "$package_path"

  install -d -m 0755 "$INSTALL_DIR" "$CONFIG_DIR" "$DATA_DIR/data" "$LOG_DIR"
  tar -xzf "$package_path" -C "$INSTALL_DIR"

  if [ ! -f "$CONFIG_DIR/gateway.env" ]; then
    install -m 0600 "$INSTALL_DIR/etc/rcodex-gateway.env.example" "$CONFIG_DIR/gateway.env"
  fi

  install -m 0644 "$INSTALL_DIR/etc/rcodex-gateway.service" /etc/systemd/system/rcodex-gateway.service
  chown -R "$SERVICE_USER:$SERVICE_USER" "$DATA_DIR" "$LOG_DIR"
  chmod +x "$INSTALL_DIR/bin/rcodex-gateway"

  systemctl daemon-reload

  echo "安装完成。请检查配置文件：$CONFIG_DIR/gateway.env"
  echo "启动服务：sudo systemctl enable --now rcodex-gateway"
}

main "$@"

