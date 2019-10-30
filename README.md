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

另外的路由当中的 analyzer 读取这里的数据进行聚合展示.

### License

MIT
