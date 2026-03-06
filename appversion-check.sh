#!/bin/sh
CURRENT=$(/usr/bin/container-version)
LATEST=$(/usr/bin/container-latest)
if [ "${CURRENT}" = "${LATEST}" ]; then
  exit 0
else
  echo "Version mismatch: current=${CURRENT} latest=${LATEST}"
  exit 1
fi
