webpack = require('./webpack.config.js')

module.exports = (config) ->
  config.set
    files: [
      'test/tests.webpack.js'
    ],

    frameworks: ['jasmine']

    webpack: webpack

    logLevel: config.LOG_DEBUG

    webpackMiddleware: {
      stats: 'none'
    }

    preprocessors:
      'test/tests.webpack.js': ['webpack']
