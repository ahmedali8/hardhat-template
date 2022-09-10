#!/usr/bin/env bash

REPOSITORY=${1?Error: Pass username/repo e.g. prb/hardhat-template}
REPOSITORY_OWNER=${2?Error: Pass username e.g. prb}

echo "REPOSITORY: $REPOSITORY"
echo "REPOSITORY_OWNER: $REPOSITORY_OWNER"

# jq is like sed for JSON data
JQ_OUTPUT=`jq \
  --arg NAME "@$REPOSITORY" \
  --arg AUTHOR_NAME "$REPOSITORY_OWNER" \
  --arg URL "https://github.com/$REPOSITORY_OWNER" \
  '.name = $NAME | .description = "" | .author |= ( .name = $AUTHOR_NAME | .url = $URL )' \
  package.json`

# overwrite package.json
echo "$JQ_OUTPUT" > package.json

# Make sed command compatible in both Mac and Linux environments
# Reference: https://stackoverflow.com/a/38595160/8696958
sedi () {
  sed --version >/dev/null 2>&1 && sed -i -- "$@" || sed -i "" "$@"
}

# Rename instances of "paulrberg/hardhat-template" to the new repo name in README.md for badges only
sedi -e '/Use this template/! s|paulrberg/hardhat-template|'${REPOSITORY}'|;' 'README.md'
