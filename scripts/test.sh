#!/bin/bash
# =============================================================================
# test.sh - Run Jest unit tests with JUnit reporting
# Jenkins Stage: Test
# Pipeline FAILS if tests fail
# =============================================================================

set -e  # Exit on error - pipeline will FAIL if tests fail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "TEST STAGE"
echo "=========================================="

cd "$PROJECT_ROOT"

# Create reports directory
mkdir -p reports

cd service

echo "Running Jest tests with JUnit reporter..."

# Run Jest with JUnit reporter for Jenkins
npm run test:ci

# Copy JUnit report to project reports directory
if [ -f "junit.xml" ]; then
    mv junit.xml "$PROJECT_ROOT/reports/junit.xml"
    echo "[OK] JUnit report: reports/junit.xml"
fi

cd "$PROJECT_ROOT"

# Generate latest.json report
cat > "reports/latest.json" << EOF
{
    "stage": "test",
    "status": "passed",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")",
    "version": "$(cat VERSION 2>/dev/null || echo "0.1.0")",
    "commit": "$(git rev-parse --short HEAD 2>/dev/null || echo "local")"
}
EOF
echo "[OK] Report: reports/latest.json"

echo ""
echo "[OK] Test stage completed successfully"
