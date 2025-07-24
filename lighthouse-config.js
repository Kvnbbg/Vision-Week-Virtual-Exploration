module.exports = {
  extends: 'lighthouse:default',
  settings: {
    onlyAudits: [
      'first-contentful-paint',
      'largest-contentful-paint',
      'first-meaningful-paint',
      'speed-index',
      'interactive',
      'cumulative-layout-shift',
      'total-blocking-time',
      'max-potential-fid',
      'server-response-time',
      'render-blocking-resources',
      'unused-css-rules',
      'unused-javascript',
      'modern-image-formats',
      'uses-optimized-images',
      'uses-webp-images',
      'uses-text-compression',
      'uses-responsive-images',
      'efficient-animated-content',
      'preload-lcp-image',
      'total-byte-weight',
      'uses-long-cache-ttl',
      'uses-rel-preconnect',
      'font-display',
      'third-party-summary',
      'third-party-facades',
      'bootup-time',
      'mainthread-work-breakdown',
      'dom-size',
      'critical-request-chains',
      'user-timings',
      'metrics'
    ],
    skipAudits: [
      'canonical',
      'robots-txt',
      'hreflang',
      'plugins',
      'charset'
    ],
    formFactor: 'mobile',
    throttling: {
      rttMs: 150,
      throughputKbps: 1638.4,
      cpuSlowdownMultiplier: 4,
      requestLatencyMs: 150,
      downloadThroughputKbps: 1638.4,
      uploadThroughputKbps: 675
    },
    screenEmulation: {
      mobile: true,
      width: 375,
      height: 667,
      deviceScaleFactor: 2,
      disabled: false
    },
    emulatedUserAgent: 'Mozilla/5.0 (Linux; Android 7.0; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4695.0 Mobile Safari/537.36 Chrome-Lighthouse'
  },
  audits: [
    'metrics/first-contentful-paint',
    'metrics/largest-contentful-paint',
    'metrics/cumulative-layout-shift',
    'metrics/total-blocking-time'
  ],
  categories: {
    performance: {
      title: 'Performance',
      auditRefs: [
        { id: 'first-contentful-paint', weight: 10, group: 'metrics' },
        { id: 'largest-contentful-paint', weight: 25, group: 'metrics' },
        { id: 'first-meaningful-paint', weight: 10, group: 'metrics' },
        { id: 'speed-index', weight: 10, group: 'metrics' },
        { id: 'interactive', weight: 10, group: 'metrics' },
        { id: 'max-potential-fid', weight: 10, group: 'metrics' },
        { id: 'cumulative-layout-shift', weight: 25, group: 'metrics' },
        { id: 'total-blocking-time', weight: 30, group: 'metrics' },
        { id: 'server-response-time', weight: 5, group: 'load-opportunities' },
        { id: 'render-blocking-resources', weight: 5, group: 'load-opportunities' },
        { id: 'unused-css-rules', weight: 5, group: 'load-opportunities' },
        { id: 'unused-javascript', weight: 5, group: 'load-opportunities' },
        { id: 'modern-image-formats', weight: 5, group: 'load-opportunities' },
        { id: 'uses-optimized-images', weight: 5, group: 'load-opportunities' },
        { id: 'uses-webp-images', weight: 5, group: 'load-opportunities' },
        { id: 'uses-text-compression', weight: 5, group: 'load-opportunities' },
        { id: 'uses-responsive-images', weight: 5, group: 'load-opportunities' },
        { id: 'efficient-animated-content', weight: 5, group: 'load-opportunities' },
        { id: 'preload-lcp-image', weight: 5, group: 'load-opportunities' },
        { id: 'total-byte-weight', weight: 5, group: 'diagnostics' },
        { id: 'uses-long-cache-ttl', weight: 5, group: 'diagnostics' },
        { id: 'uses-rel-preconnect', weight: 5, group: 'diagnostics' },
        { id: 'font-display', weight: 5, group: 'diagnostics' },
        { id: 'third-party-summary', weight: 5, group: 'diagnostics' },
        { id: 'third-party-facades', weight: 5, group: 'diagnostics' },
        { id: 'bootup-time', weight: 5, group: 'diagnostics' },
        { id: 'mainthread-work-breakdown', weight: 5, group: 'diagnostics' },
        { id: 'dom-size', weight: 5, group: 'diagnostics' },
        { id: 'critical-request-chains', weight: 5, group: 'diagnostics' },
        { id: 'user-timings', weight: 5, group: 'diagnostics' }
      ]
    }
  },
  groups: {
    'metrics': {
      title: 'Metrics'
    },
    'load-opportunities': {
      title: 'Opportunities',
      description: 'These suggestions can help your page load faster. They don\'t [directly affect](https://web.dev/performance-scoring/) the Performance score.'
    },
    'diagnostics': {
      title: 'Diagnostics',
      description: 'More information about the performance of your application. These numbers don\'t [directly affect](https://web.dev/performance-scoring/) the Performance score.'
    }
  }
};

