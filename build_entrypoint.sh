#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

docker buildx create --name=container --driver=docker-container --use --bootstrap
docker buildx build --builder container --attest=type=provenance --attest=type=sbom -t "$TAG" -f "$DOCKERFILE" --push .