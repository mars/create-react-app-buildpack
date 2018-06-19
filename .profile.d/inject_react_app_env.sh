#!/bin/bash

# Fail immediately on non-zero exit code.
set -e
# Debug, echo every command
#set -x

# Each bundle is generated with a unique hash name
# to bust browser cache.
js_bundle=/app/react-ui/build/static/js/main.*.js

if [ -f $js_bundle ]
then

  # Get exact filename.
  js_bundle_filename=`ls $js_bundle`
  
  echo "Injecting runtime env into $js_bundle_filename (from .profile.d/inject_react_app_env.sh)"

  # Render runtime env vars into bundle.
  ruby -E utf-8:utf-8 \
    -r /app/.heroku/create-react-app/injectable_env.rb \
    -e "InjectableEnv.replace('$js_bundle_filename')"
fi
