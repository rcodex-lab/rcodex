# rCodex Public Deployment

This repository contains public deployment instructions and release metadata for rCodex.

It does not contain the private rCodex application or Gateway source code. App binaries are published as GitHub Release assets. Gateway is distributed as an npm CLI package.

## Recommended Deployment Paths

- Linux / Ubuntu: `npm install -g @rcodex/gateway`
- macOS: `npm install -g @rcodex/gateway`
- Windows: `npm install -g @rcodex/gateway`
- Docker: reserved for NAS, isolated runtime, enterprise image distribution, and offline container delivery

After installation:

```bash
rcodex-gateway setup
rcodex-gateway start
```

## Release Assets

A complete App release can publish assets like:

```text
rCodex-<version>.apk
rCodex-latest.apk
rCodex-<version>.ipa
rCodex-latest.ipa
version.json
checksums.txt
```

Gateway release is handled by npm. The npm package should contain only built runtime files and package metadata. Do not publish TypeScript source, tests, `.env`, `.git`, or internal planning documents.

## Documentation

- Gateway npm deployment: `docs/deploy/npm-gateway-deployment.md`
