#!/bin/sh
if pgrep -f "Runner.Listener" > /dev/null 2>&1; then
  exit 0
else
  echo "GitHub Actions runner process not found"
  exit 1
fi
