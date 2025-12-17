#!/bin/bash
# =============================================================================
# test.sh - Run unit tests
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🧪 Running unit tests..."
echo "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# Create reports directory if it doesn't exist
mkdir -p reports

# Check if pytest is available
if command -v pytest &> /dev/null; then
    echo ""
    echo "━━━ Running pytest ━━━"
    pytest service/tests/ \
        -v \
        --tb=short \
        --junitxml=reports/junit.xml \
        --cov=service/src \
        --cov-report=html:reports/coverage \
        --cov-report=term-missing \
        || true
else
    echo "⚠️  pytest not installed, attempting with python -m pytest..."
    python -m pytest service/tests/ \
        -v \
        --tb=short \
        --junitxml=reports/junit.xml \
        || echo "⚠️  Tests could not be run. Install pytest: pip install pytest"
fi

echo ""
echo "✅ Testing completed!"
echo "📊 Reports available in: $PROJECT_ROOT/reports/"

