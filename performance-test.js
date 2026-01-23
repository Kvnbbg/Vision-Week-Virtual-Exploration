const lighthouse = require('lighthouse');
const chromeLauncher = require('chrome-launcher');
const fs = require('fs').promises;
const path = require('path');

const DEFAULT_BASE_URL = 'http://localhost:8080';
const LIGHTHOUSE_CATEGORIES = ['performance', 'accessibility', 'best-practices', 'seo'];
const DEFAULT_THRESHOLDS = Object.freeze({
  performance: 90,
  accessibility: 95,
  bestPractices: 90,
  seo: 90,
  fcp: 1800,
  lcp: 2500,
  fid: 100,
  cls: 0.1,
  tbt: 200,
  si: 3000
});
const API_ENDPOINTS = Object.freeze([
  { name: 'Get All Animals', path: '/api/animals' },
  { name: 'Search Animals', path: '/api/animals/search?q=lion' },
  { name: 'Get Animal by ID', path: '/api/animals/1' },
  { name: 'Get Categories', path: '/api/categories' },
  { name: 'Get Statistics', path: '/api/statistics' }
]);
const LOAD_TEST_USERS = Object.freeze([1, 5, 10, 20]);
const API_RESPONSE_TIME_LIMIT_MS = 500;
const LOAD_TEST_RESPONSE_TIME_LIMIT_MS = 1000;
const LOAD_TEST_SUCCESS_RATE_TARGET = 95;
const RESULTS_DIRNAME = 'results';

const logger = {
  info: (message, meta) => writeLog('info', message, meta),
  warn: (message, meta) => writeLog('warn', message, meta),
  error: (message, meta) => writeLog('error', message, meta)
};

function writeLog(level, message, meta = {}) {
  const entry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    ...meta
  };
  const payload = `${JSON.stringify(entry)}\n`;
  if (level === 'error') {
    process.stderr.write(payload);
    return;
  }
  process.stdout.write(payload);
}

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function safeJsonStringify(value) {
  try {
    return JSON.stringify(value);
  } catch (error) {
    return JSON.stringify({ error: error instanceof Error ? error.message : 'Unknown error' });
  }
}

function safeJsonParse(jsonValue) {
  try {
    return { data: JSON.parse(jsonValue), error: null };
  } catch (error) {
    return { data: null, error: error instanceof Error ? error.message : 'Unknown error' };
  }
}

function getAuditNumericValue(lhr, auditId, fallback = 0) {
  const numericValue = lhr?.audits?.[auditId]?.numericValue;
  return Number.isFinite(numericValue) ? numericValue : fallback;
}

function getCategoryScore(lhr, categoryId) {
  const score = lhr?.categories?.[categoryId]?.score;
  return Number.isFinite(score) ? Math.round(score * 100) : 0;
}

function buildUrl(baseUrl, pathName) {
  if (!isNonEmptyString(baseUrl)) {
    return null;
  }
  if (!isNonEmptyString(pathName)) {
    return baseUrl;
  }
  return `${baseUrl.replace(/\/+$/, '')}/${pathName.replace(/^\/+/, '')}`;
}

function calculatePercentage(passed, total) {
  if (total === 0) {
    return 0;
  }
  return Math.round((passed / total) * 100);
}

class PerformanceTestSuite {
  constructor(baseUrl = DEFAULT_BASE_URL) {
    this.baseUrl = isNonEmptyString(baseUrl) ? baseUrl : DEFAULT_BASE_URL;
    this.results = {};
    this.thresholds = { ...DEFAULT_THRESHOLDS };
  }

  /**
   * Runs a Lighthouse audit against a URL.
   * @param {string} url - Absolute URL to audit.
   * @param {object} options - Lighthouse options overrides.
   * @returns {Promise<object>} Lighthouse runner result.
   */
  async runLighthouseAudit(url, options = {}) {
    if (!isNonEmptyString(url)) {
      throw new Error('Invalid URL provided to Lighthouse audit.');
    }
    let chrome = null;
    try {
      chrome = await chromeLauncher.launch({ chromeFlags: ['--headless'] });
      const lighthouseOptions = {
        logLevel: 'info',
        output: 'json',
        onlyCategories: LIGHTHOUSE_CATEGORIES,
        port: chrome.port,
        ...options
      };

      const config = require('./lighthouse-config.js');
      return await lighthouse(url, lighthouseOptions, config);
    } finally {
      if (chrome) {
        await chrome.kill();
      }
    }
  }

  /**
   * Runs a Lighthouse audit for a named page and stores the results.
   * @param {string} pageName - Human readable page name.
   * @param {string} url - Absolute URL for the page.
   * @returns {Promise<object>} Stored result entry.
   */
  async testPagePerformance(pageName, url) {
    if (!isNonEmptyString(pageName) || !isNonEmptyString(url)) {
      const errorMessage = 'Page name and URL are required for performance testing.';
      logger.error(errorMessage, { pageName, url });
      this.results[pageName || 'unknown-page'] = {
        url: url || null,
        timestamp: new Date().toISOString(),
        error: errorMessage,
        passed: false
      };
      return this.results[pageName || 'unknown-page'];
    }

    logger.info('Testing page performance.', { pageName, url });
    try {
      const result = await this.runLighthouseAudit(url);
      const lhr = result.lhr;

      const metrics = {
        performance: getCategoryScore(lhr, 'performance'),
        accessibility: getCategoryScore(lhr, 'accessibility'),
        bestPractices: getCategoryScore(lhr, 'best-practices'),
        seo: getCategoryScore(lhr, 'seo'),
        fcp: getAuditNumericValue(lhr, 'first-contentful-paint'),
        lcp: getAuditNumericValue(lhr, 'largest-contentful-paint'),
        cls: getAuditNumericValue(lhr, 'cumulative-layout-shift'),
        tbt: getAuditNumericValue(lhr, 'total-blocking-time'),
        si: getAuditNumericValue(lhr, 'speed-index'),
        tti: getAuditNumericValue(lhr, 'interactive'),
        serverResponseTime: getAuditNumericValue(lhr, 'server-response-time'),
        totalByteWeight: getAuditNumericValue(lhr, 'total-byte-weight'),
        domSize: getAuditNumericValue(lhr, 'dom-size')
      };

      const opportunities = this.extractOpportunities(lhr);
      const diagnostics = this.extractDiagnostics(lhr);

      this.results[pageName] = {
        url,
        timestamp: new Date().toISOString(),
        metrics,
        opportunities,
        diagnostics,
        passed: this.checkThresholds(metrics),
        rawResult: lhr
      };

      logger.info('Page performance test completed.', { pageName });
      return this.results[pageName];

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Error testing page performance.', { pageName, error: errorMessage });
      this.results[pageName] = {
        url,
        timestamp: new Date().toISOString(),
        error: errorMessage,
        passed: false
      };
      return this.results[pageName];
    }
  }

  /**
   * Extracts Lighthouse opportunity audits for a result.
   * @param {object} lhr - Lighthouse result payload.
   * @returns {Array<object>} Sorted opportunity list.
   */
  extractOpportunities(lhr) {
    const opportunities = [];
    const auditIds = [
      'render-blocking-resources',
      'unused-css-rules',
      'unused-javascript',
      'modern-image-formats',
      'uses-optimized-images',
      'uses-webp-images',
      'uses-text-compression',
      'uses-responsive-images',
      'efficient-animated-content',
      'preload-lcp-image'
    ];

    auditIds.forEach(auditId => {
      const audit = lhr?.audits?.[auditId];
      if (audit && audit.details && audit.details.overallSavingsMs > 0) {
        opportunities.push({
          id: auditId,
          title: audit.title,
          description: audit.description,
          savingsMs: audit.details.overallSavingsMs,
          savingsBytes: audit.details.overallSavingsBytes || 0,
          score: audit.score
        });
      }
    });

    return opportunities.sort((a, b) => b.savingsMs - a.savingsMs);
  }

  /**
   * Extracts Lighthouse diagnostic audits for a result.
   * @param {object} lhr - Lighthouse result payload.
   * @returns {Array<object>} Diagnostic list.
   */
  extractDiagnostics(lhr) {
    const diagnostics = [];
    const auditIds = [
      'total-byte-weight',
      'uses-long-cache-ttl',
      'uses-rel-preconnect',
      'font-display',
      'third-party-summary',
      'bootup-time',
      'mainthread-work-breakdown',
      'dom-size',
      'critical-request-chains'
    ];

    auditIds.forEach(auditId => {
      const audit = lhr?.audits?.[auditId];
      if (audit) {
        diagnostics.push({
          id: auditId,
          title: audit.title,
          description: audit.description,
          displayValue: audit.displayValue,
          score: audit.score,
          numericValue: audit.numericValue
        });
      }
    });

    return diagnostics;
  }

  /**
   * Evaluates Lighthouse metrics against configured thresholds.
   * @param {object} metrics - Metrics payload.
   * @returns {{passed: boolean, checks: object}} Results with per-metric checks.
   */
  checkThresholds(metrics) {
    const checks = {
      performance: metrics.performance >= this.thresholds.performance,
      accessibility: metrics.accessibility >= this.thresholds.accessibility,
      bestPractices: metrics.bestPractices >= this.thresholds.bestPractices,
      seo: metrics.seo >= this.thresholds.seo,
      fcp: metrics.fcp <= this.thresholds.fcp,
      lcp: metrics.lcp <= this.thresholds.lcp,
      cls: metrics.cls <= this.thresholds.cls,
      tbt: metrics.tbt <= this.thresholds.tbt,
      si: metrics.si <= this.thresholds.si
    };

    const passed = Object.values(checks).every(check => check);
    return { passed, checks };
  }

  /**
   * Runs API performance checks for known endpoints.
   * @returns {Promise<object>} API performance results.
   */
  async testApiPerformance() {
    logger.info('Testing API performance.');
    const apiResults = {};

    for (const endpoint of API_ENDPOINTS) {
      const endpointUrl = buildUrl(this.baseUrl, endpoint.path);
      if (!endpointUrl) {
        const errorMessage = 'Invalid base URL for API testing.';
        logger.error(errorMessage, { endpoint: endpoint.name });
        apiResults[endpoint.name] = {
          url: endpointUrl,
          error: errorMessage,
          passed: false
        };
        continue;
      }
      try {
        const startTime = Date.now();
        const response = await fetch(endpointUrl);
        const endTime = Date.now();

        const responseTime = endTime - startTime;
        const responseBody = await response.text();
        const { data, error } = safeJsonParse(responseBody);
        const responseSize = safeJsonStringify(data ?? responseBody).length;

        apiResults[endpoint.name] = {
          url: endpointUrl,
          responseTime,
          status: response.status,
          size: responseSize,
          parseError: error,
          passed: responseTime < API_RESPONSE_TIME_LIMIT_MS && response.status === 200
        };

      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        apiResults[endpoint.name] = {
          url: endpointUrl,
          error: errorMessage,
          passed: false
        };
        logger.error('API performance test failed.', { endpoint: endpoint.name, error: errorMessage });
      }
    }

    this.results.api = apiResults;
    return apiResults;
  }

  /**
   * Runs load testing for the API with varying concurrent users.
   * @returns {Promise<object>} Load testing results.
   */
  async testLoadTesting() {
    logger.info('Running load testing.');
    const loadResults = {};

    const loadTestUrl = buildUrl(this.baseUrl, '/api/animals');
    if (!loadTestUrl) {
      const errorMessage = 'Invalid base URL for load testing.';
      logger.error(errorMessage);
      this.results.loadTesting = { error: errorMessage, passed: false };
      return this.results.loadTesting;
    }

    for (const users of LOAD_TEST_USERS) {
      const requests = Array.from({ length: users }, (_, index) => index);
      const promises = requests.map(async (index) => {
        const startTime = Date.now();

        try {
          const response = await fetch(loadTestUrl);
          const endTime = Date.now();

          return {
            user: index + 1,
            responseTime: endTime - startTime,
            status: response.status,
            success: response.status === 200
          };
        } catch (error) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          return {
            user: index + 1,
            error: errorMessage,
            success: false
          };
        }
      });

      const results = await Promise.all(promises);
      const successfulRequests = results.filter(r => r.success);
      const avgResponseTime = successfulRequests.length > 0
        ? successfulRequests.reduce((sum, r) => sum + r.responseTime, 0) / successfulRequests.length
        : 0;
      const successRate = (successfulRequests.length / results.length) * 100;

      loadResults[`${users}_users`] = {
        concurrentUsers: users,
        totalRequests: results.length,
        successfulRequests: successfulRequests.length,
        avgResponseTime: Math.round(avgResponseTime),
        successRate: Math.round(successRate),
        passed: successRate >= LOAD_TEST_SUCCESS_RATE_TARGET && avgResponseTime < LOAD_TEST_RESPONSE_TIME_LIMIT_MS
      };
    }

    this.results.loadTesting = loadResults;
    return loadResults;
  }

  /**
   * Runs the full performance testing suite.
   * @returns {Promise<object>} Full suite results.
   */
  async runFullTestSuite() {
    logger.info('Starting comprehensive performance test suite.');

    const pages = [
      { name: 'Home Page', url: this.baseUrl },
      { name: 'Animal Detail', url: `${this.baseUrl}/#/animal/1` },
      { name: 'Search Results', url: `${this.baseUrl}/#/search?q=lion` },
      { name: 'Category View', url: `${this.baseUrl}/#/category/mammals` }
    ];

    for (const page of pages) {
      await this.testPagePerformance(page.name, page.url);
    }

    await this.testApiPerformance();

    await this.testLoadTesting();

    const summary = this.generateSummary();
    await this.saveResults();

    logger.info('Performance test summary generated.', { summary });

    return {
      results: this.results,
      summary,
      passed: summary.overallPassed
    };
  }

  /**
   * Generates a summary of the test suite results.
   * @returns {object} Summary payload.
   */
  generateSummary() {
    const pageResults = Object.entries(this.results)
      .filter(([key]) => !['api', 'loadTesting'].includes(key))
      .map(([name, result]) => ({ name, ...result }));

    const passedPages = pageResults.filter(page => page.passed?.passed).length;
    const totalPages = pageResults.length;

    const apiResults = this.results.api || {};
    const passedApiTests = Object.values(apiResults).filter(test => test.passed).length;
    const totalApiTests = Object.keys(apiResults).length;

    const loadResults = this.results.loadTesting || {};
    const passedLoadTests = Object.values(loadResults).filter(test => test.passed).length;
    const totalLoadTests = Object.keys(loadResults).length;

    const overallPassed = passedPages === totalPages &&
                         passedApiTests === totalApiTests &&
                         passedLoadTests === totalLoadTests;

    return {
      overallPassed,
      pages: {
        passed: passedPages,
        total: totalPages,
        percentage: calculatePercentage(passedPages, totalPages)
      },
      api: {
        passed: passedApiTests,
        total: totalApiTests,
        percentage: calculatePercentage(passedApiTests, totalApiTests)
      },
      load: {
        passed: passedLoadTests,
        total: totalLoadTests,
        percentage: calculatePercentage(passedLoadTests, totalLoadTests)
      },
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Saves the results and summary to disk.
   * @returns {Promise<void>} Resolves when files are written.
   */
  async saveResults() {
    const resultsDir = path.join(__dirname, RESULTS_DIRNAME);

    try {
      await fs.mkdir(resultsDir, { recursive: true });
    } catch (error) {
      if (error instanceof Error && error.code !== 'EEXIST') {
        logger.error('Failed to create results directory.', { error: error.message });
        throw error;
      }
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `performance-results-${timestamp}.json`;
    const filepath = path.join(resultsDir, filename);

    await fs.writeFile(filepath, JSON.stringify(this.results, null, 2));
    logger.info('Results saved.', { path: filepath });

    const summaryFilename = `performance-summary-${timestamp}.json`;
    const summaryFilepath = path.join(resultsDir, summaryFilename);
    const summary = this.generateSummary();

    await fs.writeFile(summaryFilepath, JSON.stringify(summary, null, 2));
    logger.info('Summary saved.', { path: summaryFilepath });
  }
}

if (require.main === module) {
  const baseUrl = process.argv[2] || DEFAULT_BASE_URL;
  const testSuite = new PerformanceTestSuite(baseUrl);

  testSuite.runFullTestSuite()
    .then(result => {
      logger.info('Performance testing completed.', { passed: result.passed });
      process.exit(result.passed ? 0 : 1);
    })
    .catch(error => {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Performance testing failed.', { error: errorMessage });
      process.exit(1);
    });
}

module.exports = PerformanceTestSuite;
