pipeline {
    agent any

    tools {
        nodejs 'NodeJS-20'  // Configure in: Manage Jenkins → Tools
    }

    environment {
        IMAGE_NAME = 'devops-toolchain'
        VERSION = sh(script: 'cat VERSION 2>/dev/null || echo "0.1.0"', returnStdout: true).trim()
        COMMIT_HASH = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    triggers {
        // Git push triggers pipeline (requires webhook or polling)
        pollSCM('H/5 * * * *')  // Poll every 5 minutes as fallback
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                echo "=========================================="
                echo "CHECKOUT"
                echo "=========================================="
                checkout scm
                sh 'chmod +x scripts/*.sh'
                sh 'echo "Version: $(cat VERSION)"'
                sh 'echo "Commit: $(git rev-parse --short HEAD)"'
            }
        }

        stage('Install') {
            steps {
                echo "=========================================="
                echo "INSTALL DEPENDENCIES"
                echo "=========================================="
                dir('service') {
                    sh 'npm ci || npm install'
                }
            }
        }

        stage('Lint') {
            steps {
                echo "=========================================="
                echo "LINT"
                echo "=========================================="
                sh './scripts/lint.sh'
            }
            // Pipeline FAILS if lint fails (set -e in script)
        }

        stage('Test') {
            steps {
                echo "=========================================="
                echo "TEST"
                echo "=========================================="
                sh './scripts/test.sh'
            }
            post {
                always {
                    // Publish JUnit test results
                    junit allowEmptyResults: true, testResults: 'reports/junit.xml'
                }
            }
            // Pipeline FAILS if tests fail (set -e in script)
        }

        stage('Build') {
            steps {
                echo "=========================================="
                echo "BUILD"
                echo "=========================================="
                sh './scripts/build.sh'
            }
        }

        stage('Docker Build') {
            steps {
                echo "=========================================="
                echo "DOCKER BUILD"
                echo "=========================================="
                sh './scripts/docker.sh'
            }
        }

        stage('Publish') {
            when {
                branch 'main'
            }
            steps {
                echo "=========================================="
                echo "PUBLISH"
                echo "=========================================="
                sh './scripts/publish.sh'
            }
        }
    }

    post {
        always {
            echo "=========================================="
            echo "ARCHIVING ARTIFACTS"
            echo "=========================================="
            
            // Archive built packages
            archiveArtifacts artifacts: 'dist/*.tgz', 
                             allowEmptyArchive: true,
                             fingerprint: true
            
            // Archive published artifacts
            archiveArtifacts artifacts: 'artifacts/**/*', 
                             allowEmptyArchive: true,
                             fingerprint: true
            
            // Archive reports
            archiveArtifacts artifacts: 'reports/**/*', 
                             allowEmptyArchive: true
        }
        
        success {
            echo "=========================================="
            echo "PIPELINE SUCCESS"
            echo "=========================================="
            echo "Version: ${VERSION}"
            echo "Commit: ${COMMIT_HASH}"
            echo "Image: ${IMAGE_NAME}:${VERSION}-${COMMIT_HASH}"
        }
        
        failure {
            echo "=========================================="
            echo "PIPELINE FAILED"
            echo "=========================================="
        }
        
        cleanup {
            cleanWs()
        }
    }
}
