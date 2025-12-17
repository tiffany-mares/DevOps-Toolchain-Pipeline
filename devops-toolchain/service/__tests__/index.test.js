/**
 * Unit tests for index.js
 */

const {
    VERSION,
    getConfig,
    healthCheck,
    processTask,
    generateId,
    parseVersion,
    bumpVersion,
} = require('../index');

describe('getConfig', () => {
    test('returns an object', () => {
        const config = getConfig();
        expect(typeof config).toBe('object');
    });

    test('has required keys', () => {
        const config = getConfig();
        expect(config).toHaveProperty('appName');
        expect(config).toHaveProperty('environment');
        expect(config).toHaveProperty('logLevel');
        expect(config).toHaveProperty('version');
    });

    test('default app name is devops-toolchain', () => {
        const config = getConfig();
        expect(config.appName).toBe('devops-toolchain');
    });

    test('default environment is development', () => {
        const config = getConfig();
        expect(config.environment).toBe('development');
    });
});

describe('healthCheck', () => {
    test('returns an object', () => {
        const health = healthCheck();
        expect(typeof health).toBe('object');
    });

    test('status is healthy', () => {
        const health = healthCheck();
        expect(health.status).toBe('healthy');
    });

    test('includes version', () => {
        const health = healthCheck();
        expect(health).toHaveProperty('version');
        expect(health.version).toBe(VERSION);
    });

    test('includes checks', () => {
        const health = healthCheck();
        expect(health).toHaveProperty('checks');
        expect(health.checks).toHaveProperty('node');
        expect(health.checks).toHaveProperty('platform');
        expect(health.checks).toHaveProperty('uptime');
    });
});

describe('processTask', () => {
    test('returns an object', () => {
        const result = processTask('test-001', { key: 'value' });
        expect(typeof result).toBe('object');
    });

    test('includes task ID', () => {
        const taskId = 'test-002';
        const result = processTask(taskId, {});
        expect(result.taskId).toBe(taskId);
    });

    test('status is completed', () => {
        const result = processTask('test-003', {});
        expect(result.status).toBe('completed');
    });

    test('includes input data', () => {
        const data = { message: 'test' };
        const result = processTask('test-004', data);
        expect(result.input).toEqual(data);
    });

    test('includes output', () => {
        const result = processTask('test-005', { a: 1, b: 2 });
        expect(result).toHaveProperty('output');
        expect(result.output.processed).toBe(true);
        expect(result.output.itemsCount).toBe(2);
    });

    test('includes timestamp', () => {
        const result = processTask('test-006', {});
        expect(result).toHaveProperty('timestamp');
        expect(typeof result.timestamp).toBe('string');
    });
});

describe('generateId', () => {
    test('returns a string', () => {
        const id = generateId();
        expect(typeof id).toBe('string');
    });

    test('includes prefix', () => {
        const prefix = 'task';
        const id = generateId(prefix);
        expect(id.startsWith(`${prefix}-`)).toBe(true);
    });

    test('generates unique IDs', () => {
        const ids = Array.from({ length: 100 }, () => generateId());
        const uniqueIds = new Set(ids);
        expect(uniqueIds.size).toBe(ids.length);
    });
});

describe('parseVersion', () => {
    test('parses simple version', () => {
        const result = parseVersion('1.2.3');
        expect(result).toEqual({ major: 1, minor: 2, patch: 3 });
    });

    test('parses version with zeros', () => {
        const result = parseVersion('0.0.1');
        expect(result).toEqual({ major: 0, minor: 0, patch: 1 });
    });

    test('parses large version numbers', () => {
        const result = parseVersion('10.20.30');
        expect(result).toEqual({ major: 10, minor: 20, patch: 30 });
    });
});

describe('bumpVersion', () => {
    test('bumps patch version', () => {
        const result = bumpVersion('1.2.3', 'patch');
        expect(result).toBe('1.2.4');
    });

    test('bumps minor and resets patch', () => {
        const result = bumpVersion('1.2.3', 'minor');
        expect(result).toBe('1.3.0');
    });

    test('bumps major and resets others', () => {
        const result = bumpVersion('1.2.3', 'major');
        expect(result).toBe('2.0.0');
    });

    test('default bump is patch', () => {
        const result = bumpVersion('0.1.0');
        expect(result).toBe('0.1.1');
    });
});

