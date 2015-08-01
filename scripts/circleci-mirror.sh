#!/bin/sh

# http://www.yesodweb.com/blog/2015/07/s3-hackage-mirror-travis

set -eux

mkdir -p $HOME/.cabal
cat > $HOME/.cabal/config <<EOF
remote-repo: hackage.haskell.org:http://hackage.fpcomplete.com/
remote-repo-cache: $HOME/.cabal/packages
jobs: \$ncpus
EOF
