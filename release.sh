#!/bin/sh
if [ $# -ne 2 ]; then
  echo 'Usage: ./release.sh VERSION COMMIT' >&2 
  echo 'Example: ./release.sh 0.0.20190814 ed1e994d72bbd39ea729c21bbd6cbb7294ab6c36' >&2 
  exit 2
fi
export DOCKER_BUILDKIT=1
docker build -t orgalorg --build-arg VERSION=$1 --build-arg COMMIT=$2 --secret id=github_token,src=$HOME/.github_token .
