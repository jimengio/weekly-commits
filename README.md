
## Weekly commits

create `data/configs.coffee`:


```coffee
module.exports =
  # get tokens from https://github.com/settings/tokens
  token: '<token>'
  repos: [
    'jimengio/meson-form'
    'jimengio/api-base'
  ]
```

Run with:

```bash
yarn coffee grab.coffee
```

### License

MIT
