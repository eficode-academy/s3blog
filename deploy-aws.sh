#!/bin/bash

set -e

BUCKET=s3blog.praqma.com

# Deploy the site if master
if [ "${CIRCLE_BRANCH}" == "master" ]; then
  # Copy the letsencrypt files into _site
  echo "Publishing website from _site to $BUCKET..."
  cp -vR .well-known _site
  ls -al _site
  aws s3 sync --acl public-read --sse --delete _site/ s3://www.praqma.com
else
  echo "NOT Publishing website - only publishes on master branch"
fi
