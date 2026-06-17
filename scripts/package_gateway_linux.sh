#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
ARCH="${2:-x64}"

if [ -z "$VERSION" ]; then
  echo "用法: ./scripts/package_gateway_linux.sh <版本号> [x64|arm64]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATEWAY_DIR="$ROOT_DIR/services/gateway"
DIST_DIR="$ROOT_DIR/dist/native/gateway-$VERSION-linux-$ARCH"
PACKAGE_PATH="$ROOT_DIR/dist/native/rcodex-gateway-$VERSION-linux-$ARCH.tar.gz"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/bin" "$DIST_DIR/etc" "$DIST_DIR/deploy"

(cd "$GATEWAY_DIR" && npm ci && npm run build && npm prune --omit=dev)

cp -R "$GATEWAY_DIR/dist" "$DIST_DIR/dist"
cp "$GATEWAY_DIR/package.json" "$DIST_DIR/package.json"
cp "$GATEWAY_DIR/package-lock.json" "$DIST_DIR/package-lock.json"
cp -R "$GATEWAY_DIR/node_modules" "$DIST_DIR/node_modules"
cp -R "$ROOT_DIR/deploy/version" "$DIST_DIR/deploy/version"
cp "$ROOT_DIR/deploy/linux/rcodex-gateway.env.example" "$DIST_DIR/etc/rcodex-gateway.env.example"
cp "$ROOT_DIR/deploy/linux/rcodex-gateway.service" "$DIST_DIR/etc/rcodex-gateway.service"

cat >"$DIST_DIR/bin/rcodex-gateway" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SELF_DIR/.." && pwd)"
ENV_FILE="${RCODEX_GATEWAY_ENV:-/etc/rcodex/gateway.env}"

if [ "${1:-}" = "--version" ]; then
  echo "rCodex Gateway $(node -e "console.log(require('$ROOT_DIR/package.json').version)")"
  exit 0
fi

if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

cd "$ROOT_DIR"
exec node dist/index.js
EOF

chmod +x "$DIST_DIR/bin/rcodex-gateway"

"$ROOT_DIR/scripts/verify_gateway_native_package.sh" "$DIST_DIR"

mkdir -p "$(dirname "$PACKAGE_PATH")"
tar -C "$DIST_DIR" -czf "$PACKAGE_PATH" .

"$ROOT_DIR/scripts/verify_gateway_native_package.sh" "$PACKAGE_PATH"
sha256sum "$PACKAGE_PATH"

