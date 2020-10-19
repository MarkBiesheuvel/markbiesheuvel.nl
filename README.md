# markbiesheuvel.nl

Just my personal website

## Development


To install all dependencies:
```bash
yarn
```

To make a clean build:
```bash
yarn build
```

To automatically rebuild while making changes to the source
```bash
yarn watch
```

# Build


Configure CodeCommit remote (only once).
See: http://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html

```bash
git remote add aws ssh://git-codecommit.eu-central-1.amazonaws.com/v1/repos/personal-website
```

Push to this repo to deploy
```bash
git push aws
```

## Attribution

- [Twemoji](https://github.com/twitter/twemoji) - Copyright Twitter, Inc
- [Bootstrap](https://github.com/twbs/bootstrap) - Copyright Twitter, Inc.
