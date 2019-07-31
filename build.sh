#!/usr/bin/env bash

docker build --tag=qb-sso "$(dirname "${BASH_SOURCE[0]}")"

# https://medium.com/better-programming/how-to-version-your-docker-images-1d5c577ebf54
