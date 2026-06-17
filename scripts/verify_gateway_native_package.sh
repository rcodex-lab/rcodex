#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

if [ -z "$TARGET" ]; then
  echo "用法: ./scripts/verify_gateway_native_package.sh <目录|tar.gz|zip>" >&2
  exit 1
fi

if [ ! -e "$TARGET" ]; then
  echo "目标不存在: $TARGET" >&2
  exit 1
fi

list_entries() {
  case "$TARGET" in
    *.tar.gz|*.tgz)
      tar -tzf "$TARGET"
      ;;
    *.zip)
      if command -v unzip >/dev/null 2>&1; then
        unzip -Z1 "$TARGET"
      else
        python3 - "$TARGET" <<'PY'
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    for name in archive.namelist():
        print(name)
PY
      fi
      ;;
    *)
      (cd "$TARGET" && find . -print | sed 's#^\./##')
      ;;
  esac
}

entries="$(list_entries)"

blocked_pattern='(^|/)src/|\.ts$|\.test\.|(^|/)\.env$|(^|/)\.git(/|$)|(^|/)docs/plans/|(^|/)tmp(/|$)'

if printf '%s\n' "$entries" | grep -E "$blocked_pattern" >/tmp/rcodex-native-package-blocked.txt; then
  echo "原生发布包包含禁止分发内容:" >&2
  cat /tmp/rcodex-native-package-blocked.txt >&2
  exit 1
fi

required_patterns=(
  '(^|/)dist/'
  '(^|/)package.json$'
  '(^|/)package-lock.json$'
  '(^|/)deploy/version/'
  '(^|/)etc/rcodex-gateway\.env\.example$'
)

for pattern in "${required_patterns[@]}"; do
  if ! printf '%s\n' "$entries" | grep -E "$pattern" >/dev/null; then
    echo "原生发布包缺少必要内容: $pattern" >&2
    exit 1
  fi
done

echo "原生发布包校验通过: $TARGET"

