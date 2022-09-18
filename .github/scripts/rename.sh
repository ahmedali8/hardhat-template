#!/usr/bin/env bash

# Make sed command compatible in both Mac and Linux environments
# Reference: https://stackoverflow.com/a/38595160/8696958
sedi () {
  sed --version >/dev/null 2>&1 && sed -i -- "$@" || sed -i "" "$@"
}

# https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Define the input vars
REPOSITORY=${1?Error: Please pass username/repo, e.g. prb/hardhat-template}
REPOSITORY_OWNER=${2?Error: Please pass username, e.g. prb}

echo "REPOSITORY: $REPOSITORY"
echo "REPOSITORY_OWNER: $REPOSITORY_OWNER"

# jq is like sed for JSON data
JQ_OUTPUT=`jq \
  --arg NAME "@$REPOSITORY" \
  --arg AUTHOR_NAME "$REPOSITORY_OWNER" \
  --arg URL "https://github.com/$REPOSITORY_OWNER" \
  '.name = $NAME | .description = "" | .author |= ( .name = $AUTHOR_NAME | .url = $URL )' \
  package.json
`

# Overwrite package.json
echo "$JQ_OUTPUT" > package.json

# Rename instances of "paulrberg/hardhat-template" to the new repo name in README.md for badges only
sedi "/Use this template/! s|paulrberg/hardhat-template|'${REPOSITORY}'|;" "README.md"
