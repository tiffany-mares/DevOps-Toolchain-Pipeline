#!/bin/bash
# =============================================================================
# docker.sh - Build Docker image with version tagging
# Jenkins Stage: Docker Build
# Tags: name:version, name:version-commit, name:latest
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "DOCKER BUILD STAGE"
echo "=========================================="

cd "$PROJECT_ROOT"

# Check if Docker is available
if ! command -v docker &>/dev/null; then
    echo "[SKIP] Docker not installed - skipping Docker build"
    echo "       Install Docker: https://docs.docker.com/get-docker/"
    exit 0
fi

if ! docker info &>/dev/null; then
    echo "[SKIP] Docker daemon not running - skipping Docker build"
    exit 0
fi

# =============================================================================
# Version Source: VERSION file (single source of truth)
# =============================================================================
VERSION=$(cat VERSION 2>/dev/null || echo "0.1.0")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
IMAGE_NAME="devops-toolchain"

# Tags
TAG_VERSION="${IMAGE_NAME}:${VERSION}"
TAG_COMMIT="${IMAGE_NAME}:${VERSION}-${COMMIT}"
TAG_LATEST="${IMAGE_NAME}:latest"

echo "Image:   $IMAGE_NAME"
echo "Version: $VERSION"
echo "Commit:  $COMMIT"
echo ""
echo "Tags:"
echo "  - $TAG_VERSION"
echo "  - $TAG_COMMIT"
echo "  - $TAG_LATEST"
echo ""

# Build Docker image
echo "Building Docker image..."
docker build \
    -t "$TAG_VERSION" \
    -t "$TAG_COMMIT" \
    -t "$TAG_LATEST" \
    -f docker/Dockerfile \
    --build-arg VERSION="$VERSION" \
    --build-arg COMMIT_HASH="$COMMIT" \
    .

echo ""
echo "=========================================="
echo "DOCKER IMAGES"
echo "=========================================="
docker images | grep "$IMAGE_NAME" | head -5

echo ""
echo "[OK] Docker build stage completed successfully"
