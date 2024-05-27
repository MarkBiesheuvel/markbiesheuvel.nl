# markbiesheuvel.nl

Just my personal website

## Development

To install all dependencies:
```bash
npm install
```

To make a clean build:
```bash
npm run build
```

## CI/CD

Configure CodeCommit remote (only once).
See: http://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html

```bash
git remote add aws https://git-codecommit.eu-central-1.amazonaws.com/v1/repos/personalwebsite
```

Push to this repo to deploy
```bash
git push aws
```

## Attribution

- [Twemoji](https://github.com/twitter/twemoji) - Copyright Twitter, Inc
- [Bootstrap](https://github.com/twbs/bootstrap) - Copyright Twitter, Inc.
