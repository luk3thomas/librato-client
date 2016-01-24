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
          { test: /.*sinon.*\.js$/, loader: 'imports?define=>false,require=>false' }
          { test: /\.js$/
          , loader: 'babel-loader'
          , query:
            compact: false
            presets: ['es2015']
          }
        ]
      resolve:
        extensions: ['', '.coffee', '.js'],
        modulesDirectories: ['node_modules', 'src']

    webpackMiddleware:
      noInfo: true
