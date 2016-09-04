#!/usr/bin/env bash

# Fail immediately on non-zero exit code.
set -e

# Build the javascript bundle, when var is not set or equal to 'false'.
if [ 'false' == "${REACT_APP_STATEFUL_BUILD-false}" ]; then
  # Performed at runtime to pickup current `REACT_APP_*` environment variables.
  /app/.heroku/node/bin/npm run build
fi
