# =============================================================================
# DevOps Toolchain Service - Docker Image
# =============================================================================
# Build: docker build -t devops-toolchain:local -f docker/Dockerfile .
# Run:   docker run --rm devops-toolchain:local --help
# =============================================================================

FROM node:20-alpine

LABEL maintainer="DevOps Team"
LABEL description="DevOps Toolchain Service"

# Build arguments
ARG VERSION=0.1.0
ARG COMMIT_HASH=local

# Set labels
LABEL version="${VERSION}"
LABEL commit="${COMMIT_HASH}"

# Create app directory
WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy package files first (for better caching)
COPY service/package*.json ./

# Install production dependencies only
RUN npm ci --only=production 2>/dev/null || npm install --only=production

# Copy application source
COPY service/index.js ./

# Set environment variables
ENV NODE_ENV=production
ENV VERSION=${VERSION}

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "require('./index').healthCheck()" || exit 1

# Entrypoint - runs the service with any passed arguments
ENTRYPOINT ["node", "index.js"]

# Default command (can be overridden)
CMD []
