#!/bin/sh
curl -sSf https://api.github.com/repos/actions/runner/releases/latest \
  | jq -r '.tag_name' \
  | sed 's/^v//' \
  | tr -d '[:space:]'
