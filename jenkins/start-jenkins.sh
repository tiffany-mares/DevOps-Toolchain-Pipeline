#!/bin/bash
# =============================================================================
# Start Jenkins locally via Docker
# =============================================================================

set -e

echo "=========================================="
echo "Starting Jenkins (Docker)"
echo "=========================================="

# Check if Docker is available
if ! command -v docker &>/dev/null; then
    echo "[ERROR] Docker is not installed!"
    echo "        Install Docker Desktop: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &>/dev/null; then
    echo "[ERROR] Docker daemon is not running!"
    echo "        Start Docker Desktop and try again."
    exit 1
fi

# Check if Jenkins container already exists
if docker ps -a --format '{{.Names}}' | grep -q '^jenkins$'; then
    echo "Jenkins container already exists."
    
    if docker ps --format '{{.Names}}' | grep -q '^jenkins$'; then
        echo "[OK] Jenkins is already running"
    else
        echo "Starting existing Jenkins container..."
        docker start jenkins
        echo "[OK] Jenkins started"
    fi
else
    echo "Creating new Jenkins container..."
    docker run -d \
        --name jenkins \
        -p 8080:8080 \
        -p 50000:50000 \
        -v jenkins_home:/var/jenkins_home \
        -v /var/run/docker.sock:/var/run/docker.sock \
        jenkins/jenkins:lts
    echo "[OK] Jenkins container created"
fi

echo ""
echo "=========================================="
echo "Jenkins is starting up..."
echo "=========================================="
echo ""
echo "Wait ~30 seconds, then:"
echo ""
echo "1. Open:    http://localhost:8080"
echo ""
echo "2. Get password:"
echo "   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
echo "3. Install suggested plugins"
echo ""
echo "4. Create pipeline job with:"
echo "   - Type: Pipeline"
echo "   - Source: Pipeline script from SCM"
echo "   - SCM: Git"
echo "   - Script Path: Jenkinsfile"
echo ""
echo "=========================================="

