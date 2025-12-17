# Jenkins Local Setup Guide

## Prerequisites

1. **Install Docker Desktop**
   - Windows: https://docs.docker.com/desktop/install/windows-install/
   - macOS: https://docs.docker.com/desktop/install/mac-install/
   - Linux: https://docs.docker.com/engine/install/

2. **Start Docker Desktop** and ensure it's running

---

## Step 1: Run Jenkins

### Option A: Simple Docker Run
```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

### Option B: Using Docker Compose (Recommended)
```bash
cd jenkins
docker-compose up -d
```

---

## Step 2: Get Initial Admin Password

```bash
# Wait ~30 seconds for Jenkins to start, then run:
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy this password for the next step.

---

## Step 3: Access Jenkins UI

1. Open browser: **http://localhost:8080**
2. Paste the admin password from Step 2
3. Click **"Install suggested plugins"**
4. Wait for plugins to install (~2-3 minutes)
5. Create admin user or click "Skip and continue as admin"
6. Keep default Jenkins URL, click "Save and Finish"
7. Click "Start using Jenkins"

---

## Step 4: Install Additional Plugins

Go to: **Manage Jenkins → Plugins → Available plugins**

Search and install:
- ✅ **Docker Pipeline** - for Docker build steps
- ✅ **NodeJS Plugin** - for npm/node
- ✅ **Pipeline Utility Steps** - for file operations

Click "Install" and restart Jenkins when prompted.

---

## Step 5: Configure Tools

Go to: **Manage Jenkins → Tools**

### NodeJS Installation
1. Scroll to "NodeJS installations"
2. Click "Add NodeJS"
3. Name: `NodeJS-20`
4. Check "Install automatically"
5. Select version: `20.x`

### Git (Usually pre-installed)
- Should already be available

Click **Save**.

---

## Step 6: Create Pipeline Job

1. Click **"New Item"** on dashboard
2. Enter name: `devops-toolchain-pipeline`
3. Select **"Pipeline"**
4. Click **OK**

### Configure Pipeline

**General:**
- ✅ Check "Do not allow concurrent builds"

**Pipeline:**
- Definition: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: `https://github.com/YOUR_USERNAME/devops-toolchain.git`
  - Or for local testing: `/path/to/devops-toolchain`
- Branch: `*/main`
- Script Path: `Jenkinsfile`

Click **Save**.

---

## Step 7: Run the Pipeline

1. Click **"Build Now"** on the job page
2. Watch the build progress in "Build History"
3. Click on build number → "Console Output" for logs

---

## Expected Pipeline Stages

```
✅ Checkout         - Clone repository
✅ Install Deps     - npm install
✅ Lint             - ESLint checks
✅ Test             - Jest tests (24 tests)
✅ Build            - npm pack → .tgz
✅ Docker Build     - Build container image
✅ Publish          - Archive artifacts
```

---

## Useful Commands

```bash
# View Jenkins logs
docker logs -f jenkins

# Restart Jenkins
docker restart jenkins

# Stop Jenkins
docker stop jenkins

# Remove Jenkins (keeps data in volume)
docker rm jenkins

# Complete cleanup (removes data too)
docker rm jenkins
docker volume rm jenkins_home
```

---

## Troubleshooting

### "Permission denied" for Docker commands
Jenkins needs access to Docker socket. Run:
```bash
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Node/npm not found
Ensure NodeJS plugin is installed and configured in Tools.

### Pipeline fails at checkout
Check your Git repository URL and credentials.

---

## For Local Repository Testing

If your repo isn't on GitHub yet, you can mount it directly:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /path/to/devops-toolchain:/repo \
  jenkins/jenkins:lts
```

Then use `/repo` as the repository URL in the pipeline config.

