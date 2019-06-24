#!/bin/sh
set -e

# Build image (copying in documentation sources)

docker build -t doc-builder:latest -f Dockerfile.build .
rm -rf _build
mkdir _build

# Build documentation in container

docker run --rm -v "$(pwd)"/_build:/docbuild/_build doc-builder:latest


