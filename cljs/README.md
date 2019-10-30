## Data Analyzer

> in ClojureScript.

### 用法

```bash
yarn watch
```

```bash
node target/server.js
```

目前代码当中有多个入口, 暂时需要手动调整 `comment` 来切换入口(后续改成用子命令),

```clojure
(defn analyze! []
  (comment display-graph!)
  (comment write-info!)
  (daily-commits!))
```

### Workflow

https://github.com/mvc-works/calcit-nodejs-workflow

### License

MIT
