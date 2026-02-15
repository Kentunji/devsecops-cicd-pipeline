#!/bin/bash
# Test script for Stage 2: Secrets Scanning

case "$1" in
  create)
    cat > test-secret.txt << 'TESTSECRET'
# FAKE CREDENTIALS FOR TESTING
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
GITHUB_TOKEN=ghp_1234567890abcdefghijklmnopqrstuvwxyzAB
TESTSECRET
    echo "✅ Test secret created: test-secret.txt"
    echo "Next: git add test-secret.txt && git commit -m 'Test secret' && git push"
    ;;
  remove)
    git rm test-secret.txt
    echo "✅ Test secret removed"
    echo "Next: git commit -m 'Remove test secret' && git push"
    ;;
  *)
    echo "Usage: $0 {create|remove}"
    exit 1
    ;;
esac
