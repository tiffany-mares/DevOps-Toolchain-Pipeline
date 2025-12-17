# DevOps Toolchain Docker Image
# Multi-stage build for optimized image size

# =============================================================================
# Stage 1: Builder
# =============================================================================
FROM python:3.11-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY service/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Copy source code
COPY service/src/ ./src/
COPY cli/ ./cli/

# =============================================================================
# Stage 2: Production
# =============================================================================
FROM python:3.11-slim as production

LABEL maintainer="DevOps Team"
LABEL version="1.0.0"
LABEL description="DevOps Toolchain Pipeline Service"

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /root/.local /home/appuser/.local
COPY --from=builder /app/src ./src/
COPY --from=builder /app/cli ./cli/

# Set environment variables
ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)"

# Default command
CMD ["python", "src/main.py"]

