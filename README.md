## Weekly commits

创建配置文件 `data/configs.coffee`, 设置 GitHub Token, 以及需要抓取的仓库:

```coffee
module.exports =
  # get tokens from https://github.com/settings/tokens
  token: '<token>'
  repos: [
    'jimengio/meson-form'
    'jimengio/api-base'
  ]
```

运行:

```bash
cd grab/
yarn coffee grab.coffee
```

抓取的数据在 `data/commits.json` 当中.

然后可以通过进入子目录启动应用进行分析:

- [Charts](./chart-view/) 用 ECharts 展示 commits 数量相关信息.
- [cljs analyzer](./cljs/) 用 ClojureScript Node.js 脚本对数据做分组展示.

### License

MIT
