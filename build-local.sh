#!/bin/bash

set -e

echo "Building the s3blog website..."
echo "To have the same build environment as circleci use this command:"
echo "docker run -v $PWD:/srv/jekyll praqma/jekyll_cli ./build.sh"

# Build the site - from the current directory
docker run -v $PWD:/srv/jekyll praqma/jekyll_cli build
