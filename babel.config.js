module.exports = {
  presets: [
    "@babel/preset-env",
    "@babel/preset-typescript",
    "@babel/preset-react"
  ],
  plugins: [
    [
      "import",
      {
        libraryName: "antd",
        libraryDirectory: "lib",
        style: true
      }
    ]
  ]
};
