#!/bin/bash
# =============================================================================
# build.sh - Build Python package
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🏗️  Building package..."
echo "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Read version from VERSION file or default
if [ -f "VERSION" ]; then
    VERSION=$(cat VERSION)
else
    VERSION="0.1.0"
    echo "$VERSION" > VERSION
fi

echo "📦 Building version: $VERSION"

# Clean previous builds
echo ""
echo "━━━ Cleaning previous builds ━━━"
rm -rf dist/ build/ *.egg-info service/*.egg-info

# Create dist directory
mkdir -p dist

# Check if build tools are available
if command -v python &> /dev/null; then
    echo ""
    echo "━━━ Building Python package ━━━"
    
    # Check for pyproject.toml or setup.py
    if [ -f "pyproject.toml" ]; then
        python -m build || echo "⚠️  python-build not installed. Install with: pip install build"
    elif [ -f "setup.py" ]; then
        python setup.py sdist bdist_wheel || echo "⚠️  setuptools/wheel not installed"
    else
        # Create a simple source archive
        echo "Creating source archive..."
        tar -czvf "dist/devops-toolchain-${VERSION}.tar.gz" \
            --exclude='dist' \
            --exclude='reports' \
            --exclude='*.pyc' \
            --exclude='__pycache__' \
            --exclude='.git' \
            service/ cli/ scripts/
    fi
else
    echo "⚠️  Python not found!"
    exit 1
fi

echo ""
echo "✅ Build completed!"
echo "📦 Artifacts available in: $PROJECT_ROOT/dist/"
ls -la dist/

