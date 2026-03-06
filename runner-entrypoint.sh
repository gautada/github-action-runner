#!/bin/sh
set -e
cd /opt/github-actions-runner

# Configure if not already configured
if [ ! -f ".runner" ]; then
  if [ -z "${RUNNER_URL}" ] || [ -z "${RUNNER_TOKEN}" ]; then
    echo "ERROR: RUNNER_URL and RUNNER_TOKEN must be set"
    exit 1
  fi
  ./config.sh \
    --url "${RUNNER_URL}" \
    --token "${RUNNER_TOKEN}" \
    --unattended \
    --replace
fi

exec ./run.sh
