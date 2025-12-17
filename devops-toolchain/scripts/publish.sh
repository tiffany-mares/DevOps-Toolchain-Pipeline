#!/bin/bash
# =============================================================================
# publish.sh - Publish artifacts to registry
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📦 Publishing artifacts..."
echo "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Configuration
IMAGE_NAME="devops-toolchain"
REGISTRY="${DOCKER_REGISTRY:-localhost:5000}"
ARTIFACT_DIR="${ARTIFACT_DIR:-$PROJECT_ROOT/artifacts}"

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

echo "📦 Version: ${VERSION}"
echo "🏷️  Tag: ${IMAGE_TAG}"
echo "🏠 Registry: ${REGISTRY}"

# Create artifacts directory
mkdir -p "$ARTIFACT_DIR"

# =============================================================================
# Publish Python Package
# =============================================================================
echo ""
echo "━━━ Publishing Python Package ━━━"

if [ -d "dist" ] && [ "$(ls -A dist/*.whl 2>/dev/null || ls -A dist/*.tar.gz 2>/dev/null)" ]; then
    echo "Found artifacts in dist/"
    
    # Copy to artifacts directory
    cp dist/* "$ARTIFACT_DIR/" 2>/dev/null || true
    
    # Check if twine is available for PyPI publishing
    if command -v twine &> /dev/null; then
        echo "Twine available - ready for PyPI upload"
        echo "To publish to PyPI, run:"
        echo "  twine upload dist/*"
    else
        echo "⚠️  Twine not installed. Install with: pip install twine"
    fi
else
    echo "⚠️  No Python packages found in dist/"
    echo "   Run './scripts/build.sh' first"
fi

# =============================================================================
# Publish Docker Image
# =============================================================================
echo ""
echo "━━━ Publishing Docker Image ━━━"

if command -v docker &> /dev/null; then
    # Check if image exists
    if docker images | grep -q "${IMAGE_NAME}"; then
        echo "Pushing to registry: ${REGISTRY}"
        
        # Push to registry (may fail if registry is not accessible)
        docker push "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}" 2>/dev/null || \
            echo "⚠️  Could not push to ${REGISTRY} - registry may not be accessible"
        
        docker push "${REGISTRY}/${IMAGE_NAME}:latest" 2>/dev/null || \
            echo "⚠️  Could not push latest tag"
        
        # Save image as tar for offline distribution
        echo "Saving image to artifacts..."
        docker save "${IMAGE_NAME}:${IMAGE_TAG}" | gzip > "$ARTIFACT_DIR/${IMAGE_NAME}-${IMAGE_TAG}.tar.gz"
    else
        echo "⚠️  Docker image not found. Run './scripts/docker.sh' first"
    fi
else
    echo "⚠️  Docker not available"
fi

# =============================================================================
# Generate manifest
# =============================================================================
echo ""
echo "━━━ Generating Artifact Manifest ━━━"

MANIFEST_FILE="$ARTIFACT_DIR/manifest.json"
cat > "$MANIFEST_FILE" << EOF
{
    "name": "devops-toolchain",
    "version": "${VERSION}",
    "commit": "${COMMIT_HASH}",
    "tag": "${IMAGE_TAG}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "artifacts": [
        $(ls -1 "$ARTIFACT_DIR" 2>/dev/null | grep -v manifest.json | sed 's/.*/"&"/' | paste -sd, -)
    ]
}
EOF

echo "Manifest created: $MANIFEST_FILE"
cat "$MANIFEST_FILE"

echo ""
echo "✅ Publishing completed!"
echo "📁 Artifacts available in: $ARTIFACT_DIR"
ls -la "$ARTIFACT_DIR"

