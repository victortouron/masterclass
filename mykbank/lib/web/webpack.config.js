const ExtractTextPlugin = require("extract-text-webpack-plugin");
var path = require('path')

module.exports = {
  entry: './script.js',
  output: {
    path: path.resolve(__dirname, '../priv/static'),
    filename: 'bundle.js'
  },
  plugins: [
    new ExtractTextPlugin ({
      filename: 'styles.css'
    }),
  ],
  module: {
    loaders: [
      {
        test: /\.css$/,
        use:  ExtractTextPlugin.extract({use: "css-loader"})
      },
      {
        test: /.js?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        query: {
          presets: ['es2015', 'react', ['jsxz', {dir: "./"}], "stage-0"],
        // plugins: ['./my-babel-plugin']
      }
    }

  ]
},
}
