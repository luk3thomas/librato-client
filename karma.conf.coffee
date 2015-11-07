module.exports = (config) ->
  config.set
    files: [
      'test/tests.webpack.js'
    ],

    frameworks: ['jasmine']

    preprocessors:
      'test/tests.webpack.js': ['webpack']

    webpack:
      module:
        loaders: [
          { test: /\.coffee$/, loader: 'coffee' }
        ]
        resolve:
          extensions: ['', '.coffee', '.js'],

    webpackMiddleware:
      noInfo: true
