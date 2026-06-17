#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
ARCH="${2:-arm64}"

if [ -z "$VERSION" ]; then
  echo "用法: ./scripts/package_gateway_homebrew.sh <版本号> [arm64|x64]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATEWAY_DIR="$ROOT_DIR/services/gateway"
DIST_DIR="$ROOT_DIR/dist/native/gateway-$VERSION-darwin-$ARCH"
PACKAGE_PATH="$ROOT_DIR/dist/native/rcodex-gateway-$VERSION-darwin-$ARCH.tar.gz"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/bin" "$DIST_DIR/etc" "$DIST_DIR/deploy"

(cd "$GATEWAY_DIR" && npm ci && npm run build && npm prune --omit=dev)

cp -R "$GATEWAY_DIR/dist" "$DIST_DIR/dist"
cp "$GATEWAY_DIR/package.json" "$DIST_DIR/package.json"
cp "$GATEWAY_DIR/package-lock.json" "$DIST_DIR/package-lock.json"
cp -R "$GATEWAY_DIR/node_modules" "$DIST_DIR/node_modules"
cp -R "$ROOT_DIR/deploy/version" "$DIST_DIR/deploy/version"

cat >"$DIST_DIR/etc/rcodex-gateway.env.example" <<EOF
GATEWAY_HOST=0.0.0.0
GATEWAY_PORT=8787
GATEWAY_NAME=rcodex-gateway-macos
GATEWAY_VERSION=$VERSION
GATEWAY_DATA_DIR=\${HOMEBREW_PREFIX:-/opt/homebrew}/var/rcodex-gateway
GATEWAY_ALLOWED_PATHS=\$HOME/Projects
GATEWAY_UPDATE_MANIFEST_URL=https://github.com/rcodexlab/rcodex-releases/releases/latest/download/version.json
CODEX_COMMAND=codex
CODEX_APP_SERVER_PORT=8899
CODEX_APP_SERVER_STARTUP_TIMEOUT_MS=60000
GATEWAY_ENABLE_CLAUDE_CODE=false
CLAUDE_COMMAND=claude
CLAUDE_DEFAULT_MODEL=
CLAUDE_PERMISSION_MODE=default
CLAUDE_AUTO_APPROVE=false
GATEWAY_AUTH_USERNAME=admin
GATEWAY_AUTH_PASSWORD=change-this-password
GATEWAY_AUTH_TOKEN=change-this-to-a-long-random-string
EOF

cat >"$DIST_DIR/bin/rcodex-gateway" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SELF_DIR/.." && pwd)"
ENV_FILE="${RCODEX_GATEWAY_ENV:-${HOMEBREW_PREFIX:-/opt/homebrew}/etc/rcodex-gateway/gateway.env}"

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
shasum -a 256 "$PACKAGE_PATH"

