# Stage 2: Secrets Scanning

## Overview
Automated secret detection using Gitleaks to prevent hardcoded credentials.

## Tool
- **Gitleaks v2**: Detects API keys, tokens, passwords, private keys

## Workflow Steps
1. Checkout full git history
2. Run Gitleaks scanner
3. Fail pipeline if secrets detected
4. Upload SARIF report

## Testing Secret Detection

### Create test secret:
```bash
cat > test-secret.txt << 'TESTSECRET'
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
TESTSECRET

git add test-secret.txt
git commit -m "Test: Verify secret detection"
git push origin main
```
**Expected**: Pipeline FAILS ❌

### Remove test secret:
```bash
git rm test-secret.txt
git commit -m "Remove test secret"
git push origin main
```
**Expected**: Pipeline PASSES ✅

## Credentials Storage
All pipeline credentials stored in GitHub Secrets:
- `GITHUB_TOKEN` - Auto-provided by GitHub Actions
- `GITLEAKS_LICENSE` - Optional, for paid features
