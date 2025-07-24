const lighthouse = require('lighthouse');
const chromeLauncher = require('chrome-launcher');
const fs = require('fs').promises;
const path = require('path');

class PerformanceTestSuite {
  constructor(baseUrl = 'http://localhost:8080') {
    this.baseUrl = baseUrl;
    this.results = {};
    this.thresholds = {
      performance: 90,
      accessibility: 95,
      bestPractices: 90,
      seo: 90,
      fcp: 1800,      // First Contentful Paint (ms)
      lcp: 2500,      // Largest Contentful Paint (ms)
      fid: 100,       // First Input Delay (ms)
      cls: 0.1,       // Cumulative Layout Shift
      tbt: 200,       // Total Blocking Time (ms)
      si: 3000        // Speed Index (ms)
    };
  }

  async runLighthouseAudit(url, options = {}) {
    const chrome = await chromeLauncher.launch({ chromeFlags: ['--headless'] });
    
    const lighthouseOptions = {
      logLevel: 'info',
      output: 'json',
      onlyCategories: ['performance', 'accessibility', 'best-practices', 'seo'],
      port: chrome.port,
      ...options
    };

    const config = require('./lighthouse-config.js');
    const runnerResult = await lighthouse(url, lighthouseOptions, config);

    await chrome.kill();
    return runnerResult;
  }

  async testPagePerformance(pageName, url) {
    console.log(`Testing performance for ${pageName}: ${url}`);
    
    try {
      const result = await this.runLighthouseAudit(url);
      const lhr = result.lhr;

      const metrics = {
        performance: Math.round(lhr.categories.performance.score * 100),
        accessibility: Math.round(lhr.categories.accessibility.score * 100),
        bestPractices: Math.round(lhr.categories['best-practices'].score * 100),
        seo: Math.round(lhr.categories.seo.score * 100),
        fcp: lhr.audits['first-contentful-paint'].numericValue,
        lcp: lhr.audits['largest-contentful-paint'].numericValue,
        cls: lhr.audits['cumulative-layout-shift'].numericValue,
        tbt: lhr.audits['total-blocking-time'].numericValue,
        si: lhr.audits['speed-index'].numericValue,
        tti: lhr.audits['interactive'].numericValue,
        serverResponseTime: lhr.audits['server-response-time'].numericValue,
        totalByteWeight: lhr.audits['total-byte-weight'].numericValue,
        domSize: lhr.audits['dom-size'].numericValue
      };

      // Add detailed audit results
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

      console.log(`✓ ${pageName} performance test completed`);
      return this.results[pageName];

    } catch (error) {
      console.error(`✗ Error testing ${pageName}:`, error.message);
      this.results[pageName] = {
        url,
        timestamp: new Date().toISOString(),
        error: error.message,
        passed: false
      };
      return this.results[pageName];
    }
  }

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
      const audit = lhr.audits[auditId];
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
      const audit = lhr.audits[auditId];
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

  async testApiPerformance() {
    console.log('Testing API performance...');
    
    const apiEndpoints = [
      { name: 'Get All Animals', url: `${this.baseUrl}/api/animals` },
      { name: 'Search Animals', url: `${this.baseUrl}/api/animals/search?q=lion` },
      { name: 'Get Animal by ID', url: `${this.baseUrl}/api/animals/1` },
      { name: 'Get Categories', url: `${this.baseUrl}/api/categories` },
      { name: 'Get Statistics', url: `${this.baseUrl}/api/statistics` }
    ];

    const apiResults = {};

    for (const endpoint of apiEndpoints) {
      try {
        const startTime = Date.now();
        const response = await fetch(endpoint.url);
        const endTime = Date.now();
        
        const responseTime = endTime - startTime;
        const data = await response.json();

        apiResults[endpoint.name] = {
          url: endpoint.url,
          responseTime,
          status: response.status,
          size: JSON.stringify(data).length,
          passed: responseTime < 500 && response.status === 200
        };

        console.log(`✓ ${endpoint.name}: ${responseTime}ms`);

      } catch (error) {
        apiResults[endpoint.name] = {
          url: endpoint.url,
          error: error.message,
          passed: false
        };
        console.log(`✗ ${endpoint.name}: ${error.message}`);
      }
    }

    this.results.api = apiResults;
    return apiResults;
  }

  async testLoadTesting() {
    console.log('Running load testing...');
    
    const concurrentUsers = [1, 5, 10, 20];
    const loadResults = {};

    for (const users of concurrentUsers) {
      console.log(`Testing with ${users} concurrent users...`);
      
      const promises = Array(users).fill().map(async (_, index) => {
        const startTime = Date.now();
        
        try {
          const response = await fetch(`${this.baseUrl}/api/animals`);
          const endTime = Date.now();
          
          return {
            user: index + 1,
            responseTime: endTime - startTime,
            status: response.status,
            success: response.status === 200
          };
        } catch (error) {
          return {
            user: index + 1,
            error: error.message,
            success: false
          };
        }
      });

      const results = await Promise.all(promises);
      const successfulRequests = results.filter(r => r.success);
      const avgResponseTime = successfulRequests.reduce((sum, r) => sum + r.responseTime, 0) / successfulRequests.length;
      const successRate = (successfulRequests.length / results.length) * 100;

      loadResults[`${users}_users`] = {
        concurrentUsers: users,
        totalRequests: results.length,
        successfulRequests: successfulRequests.length,
        avgResponseTime: Math.round(avgResponseTime),
        successRate: Math.round(successRate),
        passed: successRate >= 95 && avgResponseTime < 1000
      };

      console.log(`✓ ${users} users: ${Math.round(avgResponseTime)}ms avg, ${Math.round(successRate)}% success`);
    }

    this.results.loadTesting = loadResults;
    return loadResults;
  }

  async runFullTestSuite() {
    console.log('🚀 Starting comprehensive performance test suite...\n');

    const pages = [
      { name: 'Home Page', url: this.baseUrl },
      { name: 'Animal Detail', url: `${this.baseUrl}/#/animal/1` },
      { name: 'Search Results', url: `${this.baseUrl}/#/search?q=lion` },
      { name: 'Category View', url: `${this.baseUrl}/#/category/mammals` }
    ];

    // Test page performance
    console.log('📊 Testing page performance...');
    for (const page of pages) {
      await this.testPagePerformance(page.name, page.url);
    }

    // Test API performance
    console.log('\n🔌 Testing API performance...');
    await this.testApiPerformance();

    // Test load performance
    console.log('\n⚡ Testing load performance...');
    await this.testLoadTesting();

    // Generate summary
    const summary = this.generateSummary();
    
    // Save results
    await this.saveResults();

    console.log('\n📋 Performance Test Summary:');
    console.log(summary);

    return {
      results: this.results,
      summary,
      passed: summary.overallPassed
    };
  }

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
        percentage: Math.round((passedPages / totalPages) * 100)
      },
      api: {
        passed: passedApiTests,
        total: totalApiTests,
        percentage: Math.round((passedApiTests / totalApiTests) * 100)
      },
      load: {
        passed: passedLoadTests,
        total: totalLoadTests,
        percentage: Math.round((passedLoadTests / totalLoadTests) * 100)
      },
      timestamp: new Date().toISOString()
    };
  }

  async saveResults() {
    const resultsDir = path.join(__dirname, 'results');
    
    try {
      await fs.mkdir(resultsDir, { recursive: true });
    } catch (error) {
      // Directory already exists
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const filename = `performance-results-${timestamp}.json`;
    const filepath = path.join(resultsDir, filename);

    await fs.writeFile(filepath, JSON.stringify(this.results, null, 2));
    console.log(`\n💾 Results saved to: ${filepath}`);

    // Also save a summary report
    const summaryFilename = `performance-summary-${timestamp}.json`;
    const summaryFilepath = path.join(resultsDir, summaryFilename);
    const summary = this.generateSummary();

    await fs.writeFile(summaryFilepath, JSON.stringify(summary, null, 2));
    console.log(`📊 Summary saved to: ${summaryFilepath}`);
  }
}

// CLI execution
if (require.main === module) {
  const baseUrl = process.argv[2] || 'http://localhost:8080';
  const testSuite = new PerformanceTestSuite(baseUrl);

  testSuite.runFullTestSuite()
    .then(result => {
      console.log('\n🎉 Performance testing completed!');
      process.exit(result.passed ? 0 : 1);
    })
    .catch(error => {
      console.error('\n❌ Performance testing failed:', error);
      process.exit(1);
    });
}

module.exports = PerformanceTestSuite;

