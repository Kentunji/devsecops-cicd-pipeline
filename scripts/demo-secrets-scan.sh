#!/bin/bash
# =============================================================================
# Task 2: Secrets Scanning Demonstration Script
# =============================================================================
# This script demonstrates the secrets scanning quality gate by:
#   1. Creating a file with a fake hardcoded secret
#   2. Committing and pushing it (pipeline should FAIL)
#   3. Removing the secret
#   4. Committing and pushing again (pipeline should PASS)
#
# Usage: ./scripts/demo-secrets-scan.sh
# =============================================================================

set -e

echo "=========================================="
echo "  Task 2: Secrets Scanning Demo"
echo "=========================================="

# Step 1: Create a file with a fake secret
echo ""
echo "[Step 1] Creating file with fake hardcoded secret..."
cat > fake-secret-demo.py << 'EOF'
# THIS FILE IS FOR DEMONSTRATION ONLY
# It contains a fake secret to trigger the Gitleaks scanner

import os

# FAKE credentials - DO NOT USE IN PRODUCTION
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
DATABASE_PASSWORD = "super_secret_password_123!"
API_TOKEN = "ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef12"

def connect_to_db():
    return f"postgresql://admin:{DATABASE_PASSWORD}@localhost:5432/mydb"
EOF

echo "   ✅ Created fake-secret-demo.py with hardcoded credentials"

# Step 2: Commit and push
echo ""
echo "[Step 2] Committing and pushing (this should FAIL the pipeline)..."
git add fake-secret-demo.py
git commit -m "test: add fake secret to demonstrate Gitleaks detection"
git push origin main

echo ""
echo "   ⏳ Check GitHub Actions - the pipeline should FAIL at the Secrets Scan stage"
echo "   🔗 Go to: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
echo ""
read -p "   Press Enter after confirming the pipeline failed..."

# Step 3: Remove the fake secret
echo ""
echo "[Step 3] Removing fake secret file..."
rm fake-secret-demo.py
git add -A
git commit -m "fix: remove hardcoded secrets (remediation)"
git push origin main

echo ""
echo "   ✅ Secret removed and pushed"
echo "   ⏳ Check GitHub Actions - the pipeline should PASS now"
echo ""
echo "=========================================="
echo "  Demo complete! Take screenshots of:"
echo "  1. The FAILED pipeline run (secrets detected)"
echo "  2. The PASSED pipeline run (secrets removed)"
echo "=========================================="
