#!/bin/sh
set -e

SENTINEL="/run/github-runner/test-mode"
RUNNER_DIR="/opt/github-actions-runner"

rm -f "${SENTINEL}"
cd "${RUNNER_DIR}"

if [ ! -f ".runner" ]; then
  if [ -z "${RUNNER_URL}" ] || [ -z "${RUNNER_TOKEN}" ]; then
    echo "INFO: RUNNER_URL and RUNNER_TOKEN are not set. Entering test mode so CI container checks can run."
    mkdir -p "$(dirname "${SENTINEL}")"
    touch "${SENTINEL}"
    exec tail -f /dev/null
  fi

  ./config.sh \
    --url "${RUNNER_URL}" \
    --token "${RUNNER_TOKEN}" \
    --unattended \
    --replace
fi

exec ./run.sh
