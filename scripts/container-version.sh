#!/bin/sh
# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ VERSION - RUNNER VERSION REPORT                                      │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
# Reports the GitHub Actions runner version.

VERSION=$(strings /home/debian/actions-runner/bin/Runner.Listener 2>/dev/null | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | head -n 1)

if [ -z "$VERSION" ]; then
  printf "unknown\n"
  exit 1
fi

printf "%s\n" "$VERSION"
