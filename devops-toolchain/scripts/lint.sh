#!/bin/bash
# =============================================================================
# lint.sh - Run code linting checks
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔍 Running linters..."
echo "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Check if Python linters are available
if command -v flake8 &> /dev/null; then
    echo ""
    echo "━━━ Running flake8 ━━━"
    flake8 service/src/ cli/ --max-line-length=100 --ignore=E501,W503 || true
else
    echo "⚠️  flake8 not installed, skipping..."
fi

if command -v black &> /dev/null; then
    echo ""
    echo "━━━ Running black (check mode) ━━━"
    black --check --diff service/src/ cli/ || true
else
    echo "⚠️  black not installed, skipping..."
fi

# Check for pylint
if command -v pylint &> /dev/null; then
    echo ""
    echo "━━━ Running pylint ━━━"
    pylint service/src/ cli/ --disable=C0114,C0115,C0116 --exit-zero || true
else
    echo "⚠️  pylint not installed, skipping..."
fi

echo ""
echo "✅ Linting completed!"

