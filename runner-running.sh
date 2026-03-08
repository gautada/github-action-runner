#!/bin/sh
SENTINEL="/run/github-runner/test-mode"

if [ -f "${SENTINEL}" ]; then
  echo "GitHub Actions runner is in CI test mode; skipping process check."
  exit 0
fi

if pgrep -f "Runner.Listener" > /dev/null 2>&1; then
  exit 0
fi

echo "GitHub Actions runner process not found"
exit 1
