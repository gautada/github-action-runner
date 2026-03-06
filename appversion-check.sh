#!/bin/sh
#
# Health check: verifies the installed runner version matches the latest
# GitHub Actions Runner release. Returns 0 on match, non-zero otherwise.

CURRENT=$(/usr/bin/container-version 2>/dev/null | tr -d '[:space:]')
LATEST=$(/usr/bin/container-latest 2>/dev/null | tr -d '[:space:]')

if [ -z "$CURRENT" ] || [ -z "$LATEST" ]; then
  echo "appversion-check: could not determine current or latest version" >&2
  exit 1
fi

printf 'Current version: %s\n' "$CURRENT"
printf 'Latest version:  %s\n' "$LATEST"

case "${LATEST}"* in
  "${CURRENT}"*)
    echo "appversion-check: version check passed"
    exit 0
    ;;
esac

echo "appversion-check: version mismatch — ${CURRENT} does not start with ${LATEST}"
exit 1
