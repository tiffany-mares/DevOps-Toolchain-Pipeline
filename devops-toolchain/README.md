# DevOps Toolchain Pipeline

A fully automated CI/CD pipeline that builds, tests, containerizes, and publishes internal automation tools, demonstrating end-to-end DevOps ownership across Linux and macOS environments.

## 🏗️ Architecture

```
Developer (Git push)
    → Jenkins CI Pipeline
    → Build & Test Stages
    → Docker Image Build
    → Artifact Publishing
    → Versioned Release
```

## 📁 Repository Structure

```
devops-toolchain/
├── Jenkinsfile          # Pipeline as code
├── README.md
├── docker/
│   └── Dockerfile       # Container definition
├── cli/
│   └── devopsctl.py     # Internal developer CLI
├── scripts/
│   ├── lint.sh          # Linting script
│   ├── test.sh          # Test runner
│   ├── build.sh         # Build script
│   ├── docker.sh        # Docker build script
│   └── publish.sh       # Artifact publish script
└── service/
    ├── src/             # Application source code
    ├── tests/           # Unit tests
    └── requirements.txt # Python dependencies
```

## 🚀 Quick Start

### One-Command Demo

```bash
# Run the complete pipeline locally
./cli/devopsctl.py all
```

### Individual Commands

```bash
# Lint the codebase
./cli/devopsctl.py lint

# Run tests
./cli/devopsctl.py test

# Build the package
./cli/devopsctl.py build

# Build Docker image
./cli/devopsctl.py docker

# Publish artifacts
./cli/devopsctl.py publish
```

## 🔧 CLI Tool (devopsctl)

The `devopsctl` CLI provides a unified interface for developers to interact with the pipeline locally and consistently.

| Command | Description |
|---------|-------------|
| `devopsctl lint` | Run linters (flake8, black) |
| `devopsctl test` | Execute unit tests (pytest) |
| `devopsctl build` | Build Python package |
| `devopsctl docker` | Build Docker image |
| `devopsctl publish` | Publish artifacts |
| `devopsctl all` | Run complete pipeline |

## 🐳 Docker

Build and run the containerized service:

```bash
# Build image
docker build -t devops-toolchain:latest -f docker/Dockerfile .

# Run container
docker run -it devops-toolchain:latest
```

## 📦 Artifact Versioning

Semantic versioning: `MAJOR.MINOR.PATCH`

- Auto-bump on main branch merge
- Tagged with version + commit hash
- Published to artifact registry

## 🖥️ Platform Support

- ✅ Linux
- ✅ macOS
- ✅ Windows (via Docker)

## 📋 Jenkins Pipeline Stages

1. **Checkout** - Clone repository
2. **Lint** - Code quality checks
3. **Unit Tests** - Run test suite
4. **Build** - Create package
5. **Docker Build** - Build container image
6. **Artifact Publish** - Push to registry
7. **Post-Build** - Notifications & archiving

## 📄 License

MIT License

