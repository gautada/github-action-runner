#!/bin/sh
#
# Health check: verifies the GitHub Actions runner listener process is active.
# Returns 0 if running, non-zero otherwise.

if pgrep -f "Runner.Listener" > /dev/null 2>&1; then
  echo "runner-running: Runner.Listener is active"
  exit 0
fi

echo "runner-running: Runner.Listener process not found"
exit 1
