module.exports = {
  entry: './src/librato-client.coffee',
  module: {
    loaders: [
      { loader: 'coffee', test: /\.coffee$/ }
    ]
  },
  output: {
    filename: 'librato-client.js',
    path: 'lib'
  },
  resolve: {
    extensions: ['', '.coffee', '.js'],
    modulesDirectories: ['node_modules', 'src']
  }
};
