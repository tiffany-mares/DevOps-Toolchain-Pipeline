# =============================================================================
# Start Jenkins locally via Docker (Windows PowerShell)
# =============================================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Starting Jenkins (Docker)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check if Docker is available
try {
    docker --version | Out-Null
} catch {
    Write-Host "[ERROR] Docker is not installed!" -ForegroundColor Red
    Write-Host "        Install Docker Desktop: https://docs.docker.com/get-docker/" -ForegroundColor Yellow
    exit 1
}

# Check if Docker daemon is running
try {
    docker info | Out-Null
} catch {
    Write-Host "[ERROR] Docker daemon is not running!" -ForegroundColor Red
    Write-Host "        Start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

# Check if Jenkins container exists
$existingContainer = docker ps -a --format '{{.Names}}' | Where-Object { $_ -eq 'jenkins' }

if ($existingContainer) {
    Write-Host "Jenkins container already exists."
    
    $runningContainer = docker ps --format '{{.Names}}' | Where-Object { $_ -eq 'jenkins' }
    
    if ($runningContainer) {
        Write-Host "[OK] Jenkins is already running" -ForegroundColor Green
    } else {
        Write-Host "Starting existing Jenkins container..."
        docker start jenkins
        Write-Host "[OK] Jenkins started" -ForegroundColor Green
    }
} else {
    Write-Host "Creating new Jenkins container..."
    docker run -d `
        --name jenkins `
        -p 8080:8080 `
        -p 50000:50000 `
        -v jenkins_home:/var/jenkins_home `
        jenkins/jenkins:lts
    Write-Host "[OK] Jenkins container created" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Jenkins is starting up..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Wait ~30 seconds, then:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open:    " -NoNewline
Write-Host "http://localhost:8080" -ForegroundColor Green
Write-Host ""
Write-Host "2. Get password:" -ForegroundColor Yellow
Write-Host "   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword" -ForegroundColor White
Write-Host ""
Write-Host "3. Install suggested plugins" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Create pipeline job with:" -ForegroundColor Yellow
Write-Host "   - Type: Pipeline" -ForegroundColor White
Write-Host "   - Source: Pipeline script from SCM" -ForegroundColor White
Write-Host "   - SCM: Git" -ForegroundColor White
Write-Host "   - Script Path: Jenkinsfile" -ForegroundColor White
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan

