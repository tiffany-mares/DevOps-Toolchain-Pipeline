#!/usr/bin/env node
/**
 * DevOps Toolchain Service
 * 
 * A sample service demonstrating the CI/CD pipeline capabilities.
 * 
 * Usage:
 *   node index.js [options]
 * 
 * Options:
 *   --help, -h       Show this help message
 *   --version, -v    Show version information
 *   --health         Run health check
 *   --run            Run the service (default)
 */

const VERSION = process.env.VERSION || '0.1.0';

// =============================================================================
// Core Functions
// =============================================================================

/**
 * Get service configuration from environment variables
 * @returns {Object} Configuration object
 */
function getConfig() {
    return {
        appName: process.env.APP_NAME || 'devops-toolchain',
        environment: process.env.ENVIRONMENT || 'development',
        logLevel: process.env.LOG_LEVEL || 'INFO',
        version: VERSION,
    };
}

/**
 * Perform a health check of the service
 * @returns {Object} Health status
 */
function healthCheck() {
    return {
        status: 'healthy',
        version: VERSION,
        checks: {
            node: process.version,
            platform: process.platform,
            uptime: process.uptime(),
        },
    };
}

/**
 * Process a task
 * @param {string} taskId - Unique task identifier
 * @param {Object} data - Task data to process
 * @returns {Object} Processing result
 */
function processTask(taskId, data) {
    console.log(`Processing task: ${taskId}`);
    
    const result = {
        taskId,
        status: 'completed',
        input: data,
        output: {
            processed: true,
            itemsCount: typeof data === 'object' ? Object.keys(data).length : 0,
        },
        timestamp: new Date().toISOString(),
    };
    
    console.log(`Task ${taskId} completed successfully`);
    return result;
}

/**
 * Generate a unique identifier
 * @param {string} prefix - Prefix for the ID
 * @returns {string} Unique identifier
 */
function generateId(prefix = 'id') {
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).substring(2, 8);
    return `${prefix}-${timestamp}-${random}`;
}

/**
 * Parse a semantic version string
 * @param {string} versionString - Version string (e.g., "1.2.3")
 * @returns {Object} Parsed version object
 */
function parseVersion(versionString) {
    const parts = versionString.split('.').map(Number);
    return {
        major: parts[0] || 0,
        minor: parts[1] || 0,
        patch: parts[2] || 0,
    };
}

/**
 * Bump a semantic version
 * @param {string} versionString - Current version string
 * @param {string} bumpType - Type of bump ("major", "minor", "patch")
 * @returns {string} New version string
 */
function bumpVersion(versionString, bumpType = 'patch') {
    const version = parseVersion(versionString);
    
    switch (bumpType) {
    case 'major':
        version.major += 1;
        version.minor = 0;
        version.patch = 0;
        break;
    case 'minor':
        version.minor += 1;
        version.patch = 0;
        break;
    case 'patch':
    default:
        version.patch += 1;
        break;
    }
    
    return `${version.major}.${version.minor}.${version.patch}`;
}

// =============================================================================
// CLI Commands
// =============================================================================

/**
 * Show help message
 */
function showHelp() {
    console.log(`
DevOps Toolchain Service v${VERSION}

A sample service demonstrating CI/CD pipeline capabilities.

USAGE:
    node index.js [OPTIONS]
    docker run --rm devops-toolchain:local [OPTIONS]

OPTIONS:
    --help, -h       Show this help message
    --version, -v    Show version information
    --health         Run health check and exit
    --run            Run the service (default)

EXAMPLES:
    node index.js --help
    node index.js --version
    node index.js --health
    node index.js --run

ENVIRONMENT VARIABLES:
    APP_NAME         Application name (default: devops-toolchain)
    ENVIRONMENT      Runtime environment (default: development)
    LOG_LEVEL        Logging level (default: INFO)
    VERSION          Version override
`);
}

/**
 * Show version information
 */
function showVersion() {
    console.log(`devops-toolchain-service v${VERSION}`);
    console.log(`Node.js ${process.version}`);
    console.log(`Platform: ${process.platform}`);
}

/**
 * Run health check and print result
 */
function runHealthCheck() {
    const health = healthCheck();
    console.log(JSON.stringify(health, null, 2));
    process.exit(health.status === 'healthy' ? 0 : 1);
}

/**
 * Main service entry point
 */
function main() {
    console.log('='.repeat(50));
    console.log('DevOps Toolchain Service Starting...');
    console.log('='.repeat(50));
    
    const config = getConfig();
    console.log('Configuration:', JSON.stringify(config, null, 2));
    
    const health = healthCheck();
    console.log('Health check:', JSON.stringify(health, null, 2));
    
    const sampleTask = processTask('demo-001', { 
        message: 'Hello from DevOps Toolchain!', 
    });
    console.log('Sample task result:', JSON.stringify(sampleTask, null, 2));
    
    console.log('='.repeat(50));
    console.log('Service initialization complete!');
    console.log('='.repeat(50));
}

// =============================================================================
// CLI Entry Point
// =============================================================================

function cli() {
    const args = process.argv.slice(2);
    
    // Parse arguments
    if (args.includes('--help') || args.includes('-h')) {
        showHelp();
        process.exit(0);
    }
    
    if (args.includes('--version') || args.includes('-v')) {
        showVersion();
        process.exit(0);
    }
    
    if (args.includes('--health')) {
        runHealthCheck();
    }
    
    // Default: run the service
    main();
}

// Run CLI if executed directly
if (require.main === module) {
    cli();
}

// Export functions for testing and programmatic use
module.exports = {
    VERSION,
    getConfig,
    healthCheck,
    processTask,
    generateId,
    parseVersion,
    bumpVersion,
    main,
};
