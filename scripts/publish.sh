#!/bin/bash
# =============================================================================
# publish.sh - Publish artifacts to artifact repository
# Jenkins Stage: Publish
# Structure: artifacts/<name>/<version>/
# Naming: name-version-commit.tgz
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "PUBLISH STAGE"
echo "=========================================="

cd "$PROJECT_ROOT"

# =============================================================================
# Version Source: VERSION file (single source of truth)
# =============================================================================
VERSION=$(cat VERSION 2>/dev/null || echo "0.1.0")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
NAME="devops-toolchain-service"
IMAGE_NAME="devops-toolchain"

# Artifact directory structure: artifacts/<name>/<version>/
ARTIFACT_DIR="$PROJECT_ROOT/artifacts/${NAME}/${VERSION}"

echo "Name:       $NAME"
echo "Version:    $VERSION"
echo "Commit:     $COMMIT"
echo "Tag:        ${NAME}-${VERSION}-${COMMIT}"
echo "Output:     artifacts/${NAME}/${VERSION}/"
echo ""

# Create artifact directory
mkdir -p "$ARTIFACT_DIR"

# =============================================================================
# Copy NPM Package
# =============================================================================
echo "Publishing NPM package..."

TAGGED_TGZ="${NAME}-${VERSION}-${COMMIT}.tgz"
VERSIONED_TGZ="${NAME}-${VERSION}.tgz"

if [ -f "dist/${TAGGED_TGZ}" ]; then
    cp "dist/${TAGGED_TGZ}" "$ARTIFACT_DIR/"
    echo "  [OK] ${TAGGED_TGZ}"
elif [ -f "dist/${VERSIONED_TGZ}" ]; then
    # Rename with commit hash if not already tagged
    cp "dist/${VERSIONED_TGZ}" "$ARTIFACT_DIR/${TAGGED_TGZ}"
    echo "  [OK] ${TAGGED_TGZ}"
else
    echo "  [FAIL] No .tgz found in dist/"
    echo "         Run ./scripts/build.sh first"
    exit 1
fi

# =============================================================================
# Save Docker Image (if available)
# =============================================================================
echo ""
echo "Publishing Docker image..."

DOCKER_TAR="${IMAGE_NAME}-${VERSION}-${COMMIT}.tar.gz"

if command -v docker &>/dev/null && docker image inspect "${IMAGE_NAME}:${VERSION}" &>/dev/null 2>&1; then
    docker save "${IMAGE_NAME}:${VERSION}" | gzip > "$ARTIFACT_DIR/${DOCKER_TAR}"
    echo "  [OK] ${DOCKER_TAR}"
else
    echo "  [SKIP] Docker image not available"
fi

# =============================================================================
# Create Manifest
# =============================================================================
echo ""
echo "Creating manifest..."

ARTIFACTS_LIST=$(ls -1 "$ARTIFACT_DIR" 2>/dev/null | grep -v manifest.json | sed 's/.*/"&"/' | paste -sd, - || echo "")

cat > "$ARTIFACT_DIR/manifest.json" << EOF
{
    "name": "${NAME}",
    "version": "${VERSION}",
    "commit": "${COMMIT}",
    "tag": "${NAME}-${VERSION}-${COMMIT}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")",
    "artifacts": [${ARTIFACTS_LIST}]
}
EOF
echo "  [OK] manifest.json"

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=========================================="
echo "PUBLISHED ARTIFACTS"
echo "=========================================="
echo "Location: artifacts/${NAME}/${VERSION}/"
echo ""
ls -la "$ARTIFACT_DIR/"

echo ""
echo "Manifest:"
cat "$ARTIFACT_DIR/manifest.json"

echo ""
echo "[OK] Publish stage completed successfully"
