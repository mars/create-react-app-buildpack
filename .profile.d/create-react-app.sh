#!/usr/bin/env bash

# Fail immediately on non-zero exit code.
set -e

# Build the javascript bundle.
# Performed at runtime to pickup current `REACT_APP_*` environment variables.
/app/.heroku/node/bin/npm run build
