#!/bin/bash
# =============================================================================
# docker.sh - Build Docker image
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🐳 Building Docker image..."
echo "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Configuration
IMAGE_NAME="devops-toolchain"
REGISTRY="${DOCKER_REGISTRY:-localhost:5000}"

# Read version
if [ -f "VERSION" ]; then
    VERSION=$(cat VERSION)
else
    VERSION="0.1.0"
fi

# Get git commit hash
if command -v git &> /dev/null && [ -d ".git" ]; then
    COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
else
    COMMIT_HASH="unknown"
fi

IMAGE_TAG="${VERSION}-${COMMIT_HASH}"

echo "📦 Image: ${IMAGE_NAME}"
echo "🏷️  Tag: ${IMAGE_TAG}"
echo "🏷️  Latest tag: latest"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

# Build the Docker image
echo ""
echo "━━━ Building Docker image ━━━"
docker build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    -t "${IMAGE_NAME}:latest" \
    -t "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" \
    -t "${REGISTRY}/${IMAGE_NAME}:latest" \
    -f docker/Dockerfile \
    --build-arg VERSION="${VERSION}" \
    --build-arg COMMIT_HASH="${COMMIT_HASH}" \
    .

echo ""
echo "━━━ Built images ━━━"
docker images | grep "${IMAGE_NAME}" | head -10

echo ""
echo "✅ Docker build completed!"
echo ""
echo "To run the container:"
echo "  docker run -it ${IMAGE_NAME}:latest"

