/**
 * DevOps Toolchain Service
 * 
 * A sample service demonstrating the CI/CD pipeline capabilities.
 */

const VERSION = '0.1.0';

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

/**
 * Main entry point
 */
function main() {
    console.log('='.repeat(50));
    console.log('DevOps Toolchain Service Starting...');
    console.log('='.repeat(50));
    
    const config = getConfig();
    console.log('Configuration:', config);
    
    const health = healthCheck();
    console.log('Health check:', health);
    
    const sampleTask = processTask('demo-001', { message: 'Hello from DevOps Toolchain!' });
    console.log('Sample task result:', sampleTask);
    
    console.log('='.repeat(50));
    console.log('Service initialization complete!');
    console.log('='.repeat(50));
}

// Run main if executed directly
if (require.main === module) {
    main();
}

// Export functions for testing
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

