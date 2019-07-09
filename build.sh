#!/bin/sh
set -e

# Build image (copying in documentation sources)
# default to master branch, can be overriden
build_stream=${1:-edinburgh}

docker build -t doc-builder:latest -f Dockerfile.build --build-arg STREAM=${build_stream} .
rm -rf _build
mkdir _build

# Build documentation in container

docker run --rm -v "$(pwd)"/_build:/docbuild/_build doc-builder:latest


