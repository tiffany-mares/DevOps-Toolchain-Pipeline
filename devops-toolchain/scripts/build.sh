#!/bin/bash
# =============================================================================
# build.sh - Build NPM package with version tagging
# Jenkins Stage: Build
# Artifact naming: name-version-commit.tgz
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "BUILD STAGE"
echo "=========================================="

cd "$PROJECT_ROOT"

# =============================================================================
# Version Source: VERSION file (single source of truth)
# =============================================================================
VERSION=$(cat VERSION 2>/dev/null || echo "0.1.0")
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
NAME="devops-toolchain-service"

echo "Name:    $NAME"
echo "Version: $VERSION"
echo "Commit:  $COMMIT"
echo "Tag:     ${NAME}-${VERSION}-${COMMIT}"
echo ""

# Clean previous builds
rm -rf dist
mkdir -p dist

cd service

# Sync VERSION to package.json
echo "Syncing version to package.json..."
npm version "$VERSION" --no-git-tag-version --allow-same-version 2>/dev/null || true

# Build NPM package
echo ""
echo "Running npm pack..."
npm pack

# Rename artifact with commit hash: name-version-commit.tgz
ORIGINAL_TGZ="${NAME}-${VERSION}.tgz"
TAGGED_TGZ="${NAME}-${VERSION}-${COMMIT}.tgz"

if [ -f "$ORIGINAL_TGZ" ]; then
    mv "$ORIGINAL_TGZ" "$PROJECT_ROOT/dist/${TAGGED_TGZ}"
    echo ""
    echo "[OK] Artifact: dist/${TAGGED_TGZ}"
fi

# Also keep a latest copy without commit hash for convenience
cp "$PROJECT_ROOT/dist/${TAGGED_TGZ}" "$PROJECT_ROOT/dist/${NAME}-${VERSION}.tgz"

cd "$PROJECT_ROOT"

echo ""
echo "=========================================="
echo "BUILD ARTIFACTS"
echo "=========================================="
ls -la dist/

echo ""
echo "[OK] Build stage completed successfully"
