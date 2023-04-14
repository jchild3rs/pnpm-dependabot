# pnpm-dependabot

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
        with:
          version: 7
          run_install: false
      - uses: actions/setup-node@v3
      - name: run the audit
        run: ./action.yml
```
