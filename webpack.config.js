module.exports = {
  entry: './src/librato-client.coffee',
  module: {
    loaders: [
      { loader: 'coffee', test: /\.coffee$/ }
    ]
  },
  output: {
    filename: 'lib/librato-client.js',
    library: 'LibratoClient',
    libraryTarget: 'umd'
  },
  resolve: {
    extensions: ['', '.coffee', '.js'],
    modulesDirectories: ['node_modules', 'src']
  }
};
