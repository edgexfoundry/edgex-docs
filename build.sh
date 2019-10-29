#!/bin/sh
set -e

# Build image (copying in documentation sources)
# default to master branch, can be overriden
build_stream=${1:-fuji}

docker build -t doc-builder:latest -f Dockerfile.build --build-arg STREAM=${build_stream} .
rm -rf docs/_build
mkdir -p docs/_build

# Build documentation in container
docker run --rm -v "$(pwd)"/docs/_build:/docbuild/_build doc-builder:latest


