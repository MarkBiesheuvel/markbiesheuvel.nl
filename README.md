markbiesheuvel.nl
==

Just my personal website

Development
--

To install all dependencies

    yarn

To make a clean build

    yarn build

To automatically rebuild while making changes to the source

    yarn watch

Build
--

Configure CodeCommit remote (only once).
See: http://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html

    git remote add aws ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/markbiesheuvel.nl

Push to this repo to deploy

    git push aws
