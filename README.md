# rCodex Public Deployment

This repository contains public deployment templates, install scripts, and release metadata for rCodex Gateway.

It does not contain the private rCodex application or Gateway source code. Runtime packages are published separately as GitHub Release assets.

## Recommended Deployment Paths

- Linux / Ubuntu: native tarball + systemd
- macOS: Homebrew native service
- Windows: native install script / Windows service preview
- Docker: reserved for NAS, isolated runtime, enterprise image distribution, and offline container delivery

## Release Assets

A complete Gateway/App release can publish assets like:

```text
rCodex-<version>.apk
rCodex-latest.apk
rCodex-<version>.ipa
rCodex-latest.ipa
rcodex-gateway-<version>-linux-x64.tar.gz
rcodex-gateway-<version>-linux-arm64.tar.gz
rcodex-gateway-<version>-darwin-arm64.tar.gz
rcodex-gateway-<version>-darwin-x64.tar.gz
rcodex-gateway-<version>-windows-x64.zip
version.json
checksums.txt
```

The release packages should contain only built runtime files, production dependencies, version metadata, launchers, and example configuration. Do not publish TypeScript source, tests, `.env`, `.git`, or internal planning documents.

## Documentation

- Linux native deployment: `docs/deploy/linux-native-deployment.md`
- macOS Homebrew deployment: `docs/deploy/homebrew-macos-deployment.md`
- Windows native deployment: `docs/deploy/windows-native-deployment.md`
- Native package rules: `deploy/native/README.md`

