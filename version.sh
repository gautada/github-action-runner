#!/bin/sh
jq -r '.version' /opt/github-actions-runner/package.json 2>/dev/null | tr -d '[:space:]'
