#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/opt/rcodex/gateway}"
CONFIG_DIR="${CONFIG_DIR:-/etc/rcodex}"
DATA_DIR="${DATA_DIR:-/var/lib/rcodex/gateway}"
LOG_DIR="${LOG_DIR:-/var/log/rcodex/gateway}"
REMOVE_DATA="${REMOVE_DATA:-false}"

if [ "$(id -u)" -ne 0 ]; then
  echo "请使用 root 或 sudo 执行卸载脚本。" >&2
  exit 1
fi

systemctl stop rcodex-gateway >/dev/null 2>&1 || true
systemctl disable rcodex-gateway >/dev/null 2>&1 || true
rm -f /etc/systemd/system/rcodex-gateway.service
systemctl daemon-reload

rm -rf "$INSTALL_DIR"

if [ "$REMOVE_DATA" = "true" ]; then
  rm -rf "$CONFIG_DIR/gateway.env" "$DATA_DIR" "$LOG_DIR"
  echo "已移除程序、配置、数据和日志。"
else
  echo "已移除程序和 systemd 服务，保留配置、数据和日志。"
fi

