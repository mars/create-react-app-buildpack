Heroku Buildpack for create-react-app
=====================================

Deploy React.js web apps generated with [create-react-app](https://github.com/facebook/create-react-app). Automates deployment with the built-in bundler and serves it up via [Nginx](http://nginx.org/en/). See the [introductory blog post](https://blog.heroku.com/deploying-react-with-zero-configuration) and entry in [Heroku elements](https://elements.heroku.com/buildpacks/mars/create-react-app-buildpack).

* 🚦 [Purpose](#user-content-purpose)
* ⚠️ [Requirements](#user-content-requires)
* 🚀 [Quick Start](#user-content-quick-start)
* 🛠 [Usage](#user-content-usage)
  1. [Generate a React app](#user-content-generate-a-react-app)
  1. [Make it a git repo](#user-content-make-it-a-git-repo)
  1. [Create the Heroku app](#user-content-create-the-heroku-app)
  1. [Commit & deploy ♻️](#user-content-commit--deploy-️)
  1. [Continue Development](#user-content-continue-development)
  1. [Push to Github](#user-content-push-to-github)
  1. [Testing](#user-content-testing)
* 👓 [Customization](#user-content-customization)
  * [Procfile](#user-content-procfile)
  * [Web server](#user-content-web-server)
    * [Routing](#user-content-routing)
    * [HTTPS-only](#user-content-https-only)
    * [Proxy](#user-content-proxy)
  * [Environment variables](#user-content-environment-variables)
    * [Set vars on Heroku](#user-content-set-vars-on-heroku)
    * [Set vars for local dev](#user-content-set-vars-for-local-dev)
    * [Compile-time vs Runtime](#user-content-compile-time-vs-runtime)
      * [Compile-time config](#user-content-compile-time-configuration)
      * [Runtime config](#user-content-runtime-configuration)
        * [Custom bundle location](#user-content-custom-bundle-location)
    * [using an Add-on's config](#user-content-add-on-config-vars)
  * [npm Private Packages](#user-content-npm-private-packages)
* 🕵️ [Troubleshooting](#user-content-troubleshooting)
* 📍 [Version compatibility](#user-content-version-compatibility)
* 🏙 [Architecture](#user-content-architecture-)

-----

Purpose
-------

**This buildpack deploys a React UI as a static web site.** The [Nginx](http://nginx.org/en/) web server provides optimum performance and security for the runtime. See [Architecture](#user-content-architecture-) for details.

If your goal is to make a single app that combines React UI with a server-side backend (Node, Ruby, Python…), then this buildpack is not the answer.

Check out these alternatives to use React with a server-side app:

* **[create-react-app + Node.js server](https://github.com/mars/heroku-cra-node)** ⭐️ simplest solution
* **[create-react-app + Ruby on Rails server](https://blog.heroku.com/a-rock-solid-modern-web-stack)** 

Requires
--------

* [Heroku](https://www.heroku.com/home)
  * [command-line tools (CLI)](https://toolbelt.heroku.com)
  * [a free account](https://signup.heroku.com)
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Node.js](https://nodejs.org)

Quick Start
-----------

Ensure [requirements](#user-content-requires) are met, then execute the following in a terminal.

✏️ *Replace `$APP_NAME` with the name for your unique app.*

```bash
npx create-react-app@3.x $APP_NAME
cd $APP_NAME
heroku create $APP_NAME --buildpack mars/create-react-app
git push heroku master
heroku open
```

Once deployed, [continue development](#user-content-continue-development) 🌱

For explanation about these steps, continue reading the [next section](#user-content-usage).


Usage
-----

### Generate a React app

✏️ *Replace `$APP_NAME` with the name for your unique app.*

```bash
npx create-react-app@3.x $APP_NAME
cd $APP_NAME
```

* as of create-react-app v3, it automatically performs `git init` and an initial commit
* [npx](https://medium.com/@maybekatz/introducing-npx-an-npm-package-runner-55f7d4bd282b) comes with npm 5.2+ and higher, see [instructions for older npm versions](https://gist.github.com/gaearon/4064d3c23a77c74a3614c498a8bb1c5f)
* if [yarn](https://yarnpkg.com) is installed locally, the new app will use it instead of [npm](https://www.npmjs.com)

### Create the Heroku app

✏️ *Replace `$APP_NAME` with the name for your unique app.*

```bash
heroku create $APP_NAME --buildpack mars/create-react-app
```

This command:

* sets the [app name](https://devcenter.heroku.com/articles/creating-apps#creating-a-named-app) & its default URL `https://$APP_NAME.herokuapp.com`
* sets the app to use this [buildpack](https://devcenter.heroku.com/articles/buildpacks)
* configures the [`heroku` git remote](https://devcenter.heroku.com/articles/git#creating-a-heroku-remote) in the local repo, so `git push heroku master` will push to this new Heroku app.

### Deploy ♻️

```bash
git push heroku master
```

…or if you are ever working on a branch other than `master`:

✏️ *Replace `$BRANCH_NAME` with the name for the current branch.*

```bash
git push heroku $BRANCH_NAME:master
```

### Visit the app's public URL in your browser

```bash
heroku open
```

### Visit the Heroku Dashboard for the app

Find the app on [your dashboard](https://dashboard.heroku.com).

### Continue Development

Work with your app locally using `npm start`. See: [create-react-app docs](https://github.com/facebookincubator/create-react-app#getting-started)

Then, `git commit` your changes & `git push heroku master` ♻️

### Push to Github

Eventually, to share, collaborate, or simply back-up your code, [create an empty repo at Github](https://github.com/new), and then follow the instructions shown on the repo to **push an existing repository from the command line**.

### Testing

Use [create-react-app's built-in Jest testing](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#user-content-running-tests) or whatever testing library you prefer.

[Heroku CI](https://devcenter.heroku.com/articles/heroku-ci) is supported with minimal configuration. The CI integration is compatible with npm & yarn (see [`bin/test`](bin/test)).

#### Minimal `app.json`

Heroku CI uses [`app.json`](https://devcenter.heroku.com/articles/app-json-schema) to provision test apps. To support Heroku CI, commit this minimal example `app.json`:

```json
{
  "buildpacks": [
    {
      "url": "mars/create-react-app"
    }
  ]
}
```

Customization
-------------

### Procfile

Heroku apps may declare what processes are launched for a successful deployment by way of the [`Procfile`](https://devcenter.heroku.com/articles/procfile). This buildpack's default process comes from [`heroku/static` buildpack](https://github.com/heroku/heroku-buildpack-static). (See: 🏙 [Architecture](#user-content-architecture-)). The implicit `Procfile` to start the static web server is:

```
web: bin/boot
```

To customize an app's processes, commit a `Procfile` and deploy. Include `web: bin/boot` to launch the default web process, or you may replace the default web process. Additional [process types](https://devcenter.heroku.com/articles/procfile#declaring-process-types) may be added to run any number of dynos with whatever arbitrary commands you want, and scale each independently.

🚦 *If replacing the default web process, please check this buildpack's [Purpose](#user-content-purpose) to avoid misusing this buildpack (such as running a Node server) which can lead to confusing deployment issues.*

### Web server

The web server may be [configured via the static buildpack](https://github.com/heroku/heroku-buildpack-static#configuration).

The config file `static.json` should be committed at the root of the repo. It will not be recognized, if this file in a sub-directory

The default `static.json`, if it does not exist in the repo, is:

```json
{
  "root": "build/",
  "routes": {
    "/**": "index.html"
  }
}
```

### Changing the root

If a different web server `"root"` is specified, such as with a highly customized, ejected create-react-app project, then the new bundle location may need to be [set to enable runtime environment variables](#user-content-custom-bundle-location).

### Routing

🚥 ***Client-side routing is supported by default.** Any server request that would result in 404 Not Found returns the React app.*

👓 See [custom routing w/ the static buildpack](https://github.com/heroku/heroku-buildpack-static/blob/master/README.md#user-content-custom-routes).

### HTTPS-only

Enforce secure connections by automatically redirecting insecure requests to **https://**, in `static.json`:

```json
{
  "root": "build/",
  "routes": {
    "/**": "index.html"
  },
  "https_only": true
}
```

#### Strict transport security (HSTS)

Prevent downgrade attacks with [HTTP strict transport security](https://developer.mozilla.org/en-US/docs/Web/Security/HTTP_strict_transport_security). Add HSTS `"headers"` to `static.json`.

⚠️ **Do not set HSTS headers if the app's hostname will not permantly support HTTPS/SSL/TLS.** Once HSTS is set, switching back to plain HTTP will cause security errors in browsers that received the headers, until the max-age is reached. Heroku's built-in `herokuapp.com` hostnames are safe to use with HSTS.

```json
{
  "root": "build/",
  "routes": {
    "/**": "index.html"
  },
  "https_only": true,
  "headers": {
    "/**": {
      "Strict-Transport-Security": "max-age=31557600"
    }
  }
}
```

* `max-age` is the number of seconds to enforce HTTPS since the last connection; the example is one-year

### Proxy

Proxy XHR requests from the React UI in the browser to API backends. Use to prevent same-origin errors when [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) is not supported on the backend.

#### Proxy URL prefix

To make calls through the proxy, use relative URL's in the React app which will be proxied to the configured target URL. For the example URL prefix of `/api/`, here's how the proxy would rewrite the requests:

```
/api/search-items
  → https://backend.example.com/search-items
  
/api/users/me
  → https://backend.example.com/users/me
```

You may choose any prefix and may have multiple proxies with different prefixes.

#### Proxy for deployment

The [`heroku/static` buildpack](https://github.com/heroku/heroku-buildpack-static) (see: 🏙 [Architecture](#user-content-architecture-))  provides [Proxy Backends configuration](https://github.com/heroku/heroku-buildpack-static/blob/master/README.md#proxy-backends) to utilize  Nginx for high-performance proxies in production.

Add `"proxies"` to `static.json`:

```json
{
  "root": "build/",
  "routes": {
    "/**": "index.html"
  },
  "proxies": {
    "/api/": {
      "origin": "${API_URL}"
    }
  }
}
```

Then, point the React UI app to a specific backend API:

```bash
heroku config:set API_URL="https://backend.example.com"
```

#### Proxy for local development

create-react-app itself provides a built-in [proxy for development](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#user-content-proxying-api-requests-in-development). This may be configured to match the behavior of [proxy for deployment](#user-content-proxy-for-deployment).

Add `"proxy"` to `package.json`:

```json
{
  "proxy": {
    "/api": {
      "target": "http://localhost:8000",
      "pathRewrite": {
        "^/api": "/"
      }
    }
  }
}
```

Replace `http://localhost:8000` with the URL to your local or remote backend service.


### Environment variables

[`REACT_APP_*` environment variables](https://facebook.github.io/create-react-app/docs/adding-custom-environment-variables) are fully supported with this buildpack.

🚫🤐 ***Not for secrets.** These values may be accessed by anyone who can see the React app.*

### [Set vars on Heroku](https://devcenter.heroku.com/articles/config-vars)

```bash
heroku config:set REACT_APP_HELLO='I love sushi!'
```

### Set vars for local dev

*Requires at least create-react-app 0.7. Earlier versions only support Compile-time.*

Create a `.env` file that sets a variable per line:

```bash
REACT_APP_API_URL=http://api.example.com
REACT_APP_CLIENT_ID=XyzxYzxyZ
```

### Compile-time vs Runtime

Two versions of variables are supported. In addition to compile-time variables applied during [build](https://github.com/facebookincubator/create-react-app#npm-run-build) the app supports variables set at runtime, applied as each web dyno starts-up.

Requirement | [Compile-time](#user-content-compile-time-configuration) | [Runtime](#user-content-runtime-configuration)
:--- |:---:|:---: 
never changes for a build | ✓ |  
support for [continuous delivery](https://www.heroku.com/continuous-delivery) |  | ✓
updates immediately when setting new [config vars](https://devcenter.heroku.com/articles/config-vars) |   | ✓
different values for staging & production (in a [pipeline](https://devcenter.heroku.com/articles/pipelines)) |   | ✓
ex: `REACT_APP_BUILD_VERSION` (static fact about the bundle) | ✓ | 
ex: `REACT_APP_DEBUG_ASSERTIONS` ([prune code from bundle](https://webpack.github.io/docs/list-of-plugins.html#defineplugin)) | ✓ | 
ex: `REACT_APP_API_URL` (transient, external reference) |   | ✓
ex: `REACT_APP_FILEPICKER_API_KEY` ([Add-on config vars](#user-content-add-on-config-vars)) |   | ✓

### Compile-time configuration

Supports all config vars, including [`REACT_APP_`](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables), `NODE_`, `NPM_`, & `HEROKU_` prefixed variables.

☝️🤐 ***Use secrets carefully.** If these values are embedded in the JavaScript bundle, like with `REACT_APP_` vars, then they may be accessed by anyone who can see the React app.*

Use Node's [`process.env` object](https://nodejs.org/dist/latest-v10.x/docs/api/process.html#process_process_env).

```javascript
import React, { Component } from 'react';

class App extends Component {
  render() {
    return (
      <code>Runtime env var example: { process.env.REACT_APP_HELLO }</code>
    );
  }
}
```

♻️ The app must be re-deployed for compiled changes to take effect, because during the build, these references will be replaced with their quoted string value.

```bash
heroku config:set REACT_APP_HELLO='I love sushi!'

git commit --allow-empty -m "Set REACT_APP_HELLO config var"
git push heroku master
```

Only `REACT_APP_` vars are replaced in create-react-app's build. To make any other variables visible to React, they must be prefixed for the build command in `package.json`, like this:

```bash
REACT_APP_HEROKU_SLUG_COMMIT=$HEROKU_SLUG_COMMIT react-scripts build
```

### Runtime configuration

Supports only [`REACT_APP_`](https://github.com/facebook/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables) prefixed variables.

🚫🤐 ***Not for secrets.** These values may be accessed by anyone who can see the React app.*

Install the [runtime env npm package](https://www.npmjs.com/package/@mars/heroku-js-runtime-env):

```bash
npm install @mars/heroku-js-runtime-env --save
```

Then, require/import it to use the vars within components:

```javascript
import React, { Component } from 'react';
import runtimeEnv from '@mars/heroku-js-runtime-env';

class App extends Component {
  render() {
    // Load the env object.
    const env = runtimeEnv();

    // …then use values just like `process.env`
    return (
      <code>Runtime env var example: { env.REACT_APP_HELLO }</code>
    );
  }
}
```

⚠️ *Avoid setting backslash escape sequences, such as `\n`, into Runtime config vars. Use literal UTF-8 values only; they will be automatically escaped.*

#### Custom bundle location

If the javascript bundle location is customized, such as with an ejected created-react-app project, then the runtime may not  be able to locate the bundle to inject runtime variables.

To solve this so the runtime can locate the bundle, set the custom bundle path:

```bash
heroku config:set JS_RUNTIME_TARGET_BUNDLE=/app/my/custom/path/js/*.js
```

✳️ *Note this path is a `*` glob, selecting multiple files, because as of create-react-app version 2 the [bundle is split](https://reactjs.org/blog/2018/10/01/create-react-app-v2.html).*

To unset this config and use the default path for **create-react-app**'s bundle, `/app/build/static/js/*.js`:

```bash
heroku config:unset JS_RUNTIME_TARGET_BUNDLE
```

### Add-on config vars

🚫🤐 ***Be careful not to export secrets.** These values may be accessed by anyone who can see the React app.*

Use a custom [`.profile.d` script](https://devcenter.heroku.com/articles/buildpack-api#profile-d-scripts) to make variables set by other components available to the React app by prefixing them with `REACT_APP_`.

1. create `.profile.d/000-react-app-exports.sh`
1. make it executable `chmod +x .profile.d/000-react-app-exports.sh`
1. add an `export` line for each variable:

   ```bash
   export REACT_APP_ADDON_CONFIG=${ADDON_CONFIG:-}
   ```
1. set-up & use [Runtime configuration](#user-content-runtime-configuration) to access the variables

For example, to use the API key for the [Filestack](https://elements.heroku.com/addons/filepicker) JS image uploader:

```bash
export REACT_APP_FILEPICKER_API_KEY=${FILEPICKER_API_KEY:-}
```

npm Private Packages
-------------------
Private modules are supported during build.

1. Setup your app with a `.npmrc` file following [npm's guide for CI/deployment](https://docs.npmjs.com/private-modules/ci-server-config).
1. Set your secret in the `NPM_TOKEN` config var:

    ```bash
    heroku config:set NPM_TOKEN=xxxxx
    ```

Troubleshooting
---------------

1. Confirm that your app is using this buildpack:

    ```bash
    heroku buildpacks
    ```
    
    If it's not using `create-react-app-buildpack`, then set it:

    ```bash
    heroku buildpacks:set mars/create-react-app
    ```

    …and deploy with the new buildpack:

    ```bash
    git commit --allow-empty -m 'Switch to create-react-app-buildpack'
    git push heroku master
    ```
    
    If the error still occurs, then at least we know it's really using this buildpack! Proceed with troubleshooting.
1. Check this README to see if it already mentions the issue.
1. Search our [issues](https://github.com/mars/create-react-app-buildpack/issues?utf8=✓&q=is%3Aissue%20) to see if someone else has experienced the same problem.
1. Search the internet for mentions of the error message and its subject module, e.g. `ENOENT "node-sass"`
1. File a new [issue](https://github.com/mars/create-react-app-buildpack/issues/new). Please include:
   * build log output
   * link to GitHub repo with the source code (if private, grant read access to @mars)


Version compatibility
---------------------

This buildpack will never intentionally cause previously deployed apps to become undeployable. Using master [as directed in the main instructions](#user-content-create-the-heroku-app) will always deploy an app with the most recent version of this buildpack.

[Releases are tagged](https://github.com/mars/create-react-app-buildpack/releases), so you can lock an app to a specific version, if that kind of determinism pleases you:

```bash
heroku buildpacks:set https://github.com/mars/create-react-app-buildpack.git#v6.0.0
```

✏️ *Replace `v6.0.0` with the desired [release tag](https://github.com/mars/create-react-app-buildpack/releases).*

♻️ Then, commit & deploy to rebuild on the new buildpack version.


Architecture 🏙
------------

This buildpack combines several buildpacks, specified in [`.buildpacks`](.buildpacks), to support **zero-configuration deployment** on Heroku:

1. [`heroku/nodejs` buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
   * installs `node`, puts on the `$PATH`
   * version specified in [`package.json`, `engines.node`](https://devcenter.heroku.com/articles/nodejs-support#specifying-a-node-js-version)
   * `node_modules/` cached between deployments
   * production build for create-react-app
     * [executes the npm package's build script](https://devcenter.heroku.com/changelog-items/1557); create-react-app default is `react-scripts build`
     * exposes all env vars to the build script
     * generates a production bundle regardless of `NODE_ENV` setting
     * customize further with [Node.js build configuration](https://devcenter.heroku.com/articles/nodejs-support#customizing-the-build-process)
2. [`mars/create-react-app-inner-buildpack`](https://github.com/mars/create-react-app-inner-buildpack)
   * sets default [web server config](#user-content-web-server) unless `static.json` already exists
   * enables [runtime environment variables](#user-content-environment-variables)
3. [`heroku/static` buildpack](https://github.com/heroku/heroku-buildpack-static)
   * [Nginx](http://nginx.org/en/) web server
   * [configure with `static.json`](#user-content-web-server) (see also [all static web server config](https://github.com/heroku/heroku-buildpack-static#user-content-configuration))

🚀 The runtime `web` process is the [last buildpack](https://github.com/mars/create-react-app-buildpack/blob/master/.buildpacks)'s default processes. heroku-buildpack-static uses [`bin/boot`](https://github.com/heroku/heroku-buildpack-static/blob/master/bin/release) to launch its Nginx web server. Processes may be customized by committing a [Procfile](#user-content-procfile) to the app.


### General-purpose SPA deployment

[Some kind feedback](https://github.com/mars/create-react-app-buildpack/issues/2) pointed out that this buildpack is not necessarily specific to `create-react-app`.

This buildpack can deploy any SPA [single-page app] as long as it meets the following requirements:

* `npm run build` performs the transpile/bundling
* the file `build/index.html` or [the root specified in `static.json`](#user-content-customization) exists at runtime.
