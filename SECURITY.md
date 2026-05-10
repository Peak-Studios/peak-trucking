# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 0.2.x   | ✅ Yes     |
| 0.1.x   | ❌ No      |

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Report security issues privately to the maintainers:

1. Email **abdelkarim.contact1@gmail.com** with the subject line `[SECURITY] peak-trucking`.
2. Include:
   - A clear description of the vulnerability
   - Steps to reproduce
   - Affected versions or commits
   - Suggested mitigation if known
3. You will receive an acknowledgment within 48 hours. We aim to release a patch within 7 days of confirmation.

## Sensitive Values

Do not commit any of the following to the repository:

- Discord bot tokens or webhook URLs
- Database credentials or connection strings
- Server-specific API keys or secrets

Keep server-only values in `server/server-config.lua` or a private local override file excluded by `.gitignore`.
