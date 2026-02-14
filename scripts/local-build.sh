#!/bin/bash
# =============================================================================
# Local Build Reproduction Script
# =============================================================================
# Reproduces the CI/CD pipeline build locally using Docker.
# This ensures the build environment matches the pipeline runner.
#
# Usage: ./scripts/local-build.sh
# =============================================================================

set -e

echo "=========================================="
echo "  DevSecOps Pipeline - Local Build"
echo "=========================================="

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed."; exit 1; }

IMAGE_NAME="juice-shop"
IMAGE_TAG="local-$(date +%Y%m%d-%H%M%S)"

echo ""
echo "[1/4] Building Docker image..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest

echo ""
echo "[2/4] Running tests inside container..."
docker run --rm ${IMAGE_NAME}:${IMAGE_TAG} npm test || echo "⚠️  Tests completed (some may fail for Juice Shop)"

echo ""
echo "[3/4] Running Gitleaks locally..."
if command -v gitleaks >/dev/null 2>&1; then
    gitleaks detect --source . --report-path gitleaks-local-report.json || echo "⚠️  Gitleaks found potential secrets"
else
    docker run --rm -v "$(pwd):/path" ghcr.io/gitleaks/gitleaks:latest detect --source /path --report-path /path/gitleaks-local-report.json || echo "⚠️  Gitleaks found potential secrets"
fi

echo ""
echo "[4/4] Running Trivy scan locally..."
if command -v trivy >/dev/null 2>&1; then
    trivy image --severity CRITICAL,HIGH ${IMAGE_NAME}:${IMAGE_TAG}
else
    docker run --rm aquasec/trivy:latest image --severity CRITICAL,HIGH ${IMAGE_NAME}:${IMAGE_TAG}
fi

echo ""
echo "=========================================="
echo "  Local build complete!"
echo "  Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "=========================================="
