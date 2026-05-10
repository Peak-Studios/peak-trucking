# Contributing to Peak Trucking

Thank you for your interest in improving Peak Trucking! This document explains how to contribute effectively.

## How Can I Contribute?

### Reporting Bugs

Before opening a bug report, please check the existing issues to avoid duplicates.

When filing a bug, include:
- A clear, descriptive title
- Steps to reproduce the behavior
- Expected vs. actual behavior
- Your FiveM server framework and version
- Relevant error output from the server or client console

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md).

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues.

When suggesting a feature, include:
- A clear description of the improvement and why it would be useful
- Examples of how the feature would be used
- Whether it would be a breaking change

Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md).

### Submitting Pull Requests

1. Fork the repository and create your branch from `main`.
2. Make your changes following the code style below.
3. Test your changes on a local FiveM server before submitting.
4. Open a pull request using the [PR template](.github/PULL_REQUEST_TEMPLATE.md) and describe what changed and why.

## Setup for Development

```powershell
# Clone your fork
git clone https://github.com/<your-username>/peak-trucking.git

# Build the NUI (required for any UI changes)
cd peak-trucking/ui
npm install
npm run build
```

Place the resource folder as `peak-trucking` in your FiveM server's `resources/` directory and ensure it in `server.cfg`.

## Code Style

- **Lua**: 4-space indentation, LF line endings, `---` JSDoc above all exported/public functions.
- **Section headers**: Use `-- ============================================================` to separate logical sections in Lua files.
- **No debug leaks**: Gate all `print()` calls behind `if Config.Debug then ... end`.
- **Parameterized SQL**: Use named parameters (`:param`) in all SQL queries — never string concatenation.
- **Bridge functions**: Keep all framework and inventory integrations inside `server/bridge.lua` or `shared/config.lua` hooks. Do not duplicate framework checks in `main.lua`.
- **Client events are untrusted**: Always validate important payloads server-side before acting on them.
- **TypeScript / React (NUI)**: Follow existing ESLint config. Run `npm run build` and commit `ui/dist` before opening a PR.
- **No commented-out code**: Remove dead code before opening a PR.

## Sensitive Values

Do not commit Discord bot tokens, webhooks, database credentials, or server-specific secrets. Keep server-only values in `server/server-config.lua` or a private local override file excluded by `.gitignore`.
