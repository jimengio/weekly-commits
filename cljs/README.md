## Data Analyzer

### 用法

依赖 JVM, Maven, Node.js 等...

```bash
yarn
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

- `display-graph!` 按 人/项目 罗列修改代码量
- `write-info!` 按 人/项目 分组以后直接把信息写入 `target/result.edn`
- `daily-commits!` 罗列每 天/人 的 commits 数量

### Workflow

https://github.com/mvc-works/calcit-nodejs-workflow

### License

MIT
