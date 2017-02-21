path = require('path')

module.exports = {
  entry: './src/librato-client.coffee',
  module: {
    loaders: [
      { loader: 'coffee-loader', test: /\.coffee$/ }
    ]
  },
  output: {
    filename: 'lib/librato-client.js',
    library: 'LibratoClient',
    libraryTarget: 'umd'
  },
  resolve: {
    extensions: ['.coffee', '.js'],
    modules: [
      'node_modules',
      path.join(__dirname)
    ]
  }
};
