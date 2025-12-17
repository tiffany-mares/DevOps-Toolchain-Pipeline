#!/bin/bash
# =============================================================================
# lint.sh - Run ESLint for Node.js
# Jenkins Stage: Lint
# Pipeline FAILS if lint fails
# =============================================================================

set -e  # Exit on error - pipeline will FAIL if lint fails

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "LINT STAGE"
echo "=========================================="

cd "$PROJECT_ROOT/service"

echo "Running ESLint..."
npm run lint

echo ""
echo "[OK] Lint stage completed successfully"
