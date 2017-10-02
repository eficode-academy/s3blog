#!/bin/bash
# Run a local server to serve the blog - useful for testing
docker run --rm -p 4000:4000 -itv $PWD:/srv/jekyll praqma/jekyll_cli serve
