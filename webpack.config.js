var path = require('path');

module.exports = {
  entry: './src/librato-client.coffee',
  module: {
    rules: [
      { loader: 'coffee-loader', test: /\.coffee$/ }
    ]
  },
  output: {
    filename: 'librato-client.js',
    path: __dirname + '/lib',
    library: 'LibratoClient',
    libraryTarget: 'umd'
  },
  resolve: {
    extensions: ['.coffee', '.js'],
    alias: {
      src: path.resolve(__dirname, 'src')
    }
  }
};
