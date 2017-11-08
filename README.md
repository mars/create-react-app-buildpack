Heroku Buildpack for create-react-app
=====================================

Deploy React.js web apps generated with [create-react-app](https://github.com/facebookincubator/create-react-app). Automates deployment with the built-in bundler and serves it up via [Nginx](http://nginx.org/en/). See the [introductory blog post](https://blog.heroku.com/deploying-react-with-zero-configuration) and entry in [Heroku elements](https://elements.heroku.com/buildpacks/mars/create-react-app-buildpack).

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
    * [Routing clean URLs](#user-content-routing-clean-urls)
    * [HTTPS-only](#user-content-https-only)
    * [Proxy](#user-content-proxy)
  * [Environment variables](#user-content-environment-variables)
    * [Set vars on Heroku](#user-content-set-vars-on-heroku)
    * [Set vars for local dev](#user-content-set-vars-for-local-dev)
    * [Compile-time vs Runtime](#user-content-compile-time-vs-runtime)
      * [Compile-time config](#user-content-compile-time-configuration)
      * [Runtime config](#user-content-runtime-configuration)
    * [using an Add-on's config](#user-content-add-on-config-vars)
* 🕵️ [Troubleshooting](#user-content-troubleshooting)
* 📍 [Version compatibility](#user-content-version-compatibility)
* 🏙 [Architecture](#user-content-architecture-)

-----

Purpose
-------

**This buildpack deploys a React UI as a static web site.** The [Nginx](http://nginx.org/en/) web server provides optimum performance and security for the runtime. See [Architecture](#user-content-architecture-) for details.

If your goal is to combine React UI + API (Node, Ruby, Python…) into a *single app*, then this buildpack is not the answer. The simplest combined solution is all javascript:

▶️ **[create-react-app + Node.js server](https://github.com/mars/heroku-cra-node)** on Heroku

Combination with other languages is possible too, like [create-react-app + Rails 5 server](https://medium.com/superhighfives/a-top-shelf-web-stack-rails-5-api-activeadmin-create-react-app-de5481b7ec0b).

Requires
--------

* [Heroku](https://www.heroku.com/home)
  * [command-line tools (CLI)](https://toolbelt.heroku.com)
  * [a free account](https://signup.heroku.com)
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [Node.js](https://nodejs.org)
* [create-react-app](https://github.com/facebookincubator/create-react-app)
  * `npm install -g create-react-app`

Quick Start
-----------

Ensure [requirements](#user-content-requires) are met, then execute the following in a terminal.

✏️ *Replace `$APP_NAME` with a name for your unique app.*

```bash
create-react-app $APP_NAME
cd $APP_NAME
git init
heroku create $APP_NAME --buildpack https://github.com/mars/create-react-app-buildpack.git
yarn install
git add .
git commit -m "Start with create-react-app"
git push heroku master
heroku open
```

Once deployed, [continue development](#user-content-continue-development) 🌱

For explanation about these steps, continue reading the [next section](#user-content-usage).


Usage
-----

### Generate a React app

```bash
create-react-app my-app
cd my-app
```

* If [yarn](https://yarnpkg.com) is installed locally, the new app will use it instead of [npm](https://www.npmjs.com).

### Make it a git repo

```bash
git init
```

At this point, this new repo is local, only on your computer. Eventually, you may want to [push to Github](#user-content-push-to-github).

### Create the Heroku app

```bash
heroku create $APP_NAME --buildpack https://github.com/mars/create-react-app-buildpack.git
```

✏️ *Replace `$APP_NAME` with a name for your unique app.*

This command:

* sets the [app name](https://devcenter.heroku.com/articles/creating-apps#creating-a-named-app) & its URL `https://my-app-name.herokuapp.com`
* sets the [buildpack](https://devcenter.heroku.com/articles/buildpacks) to deploy a `create-react-app` app
* configures the [`heroku` remote](https://devcenter.heroku.com/articles/git#creating-a-heroku-remote) in the local git repo, so `git push heroku master` will push to this new Heroku app.

### Commit & deploy ♻️

```bash
git add .
git commit -m "Start with create-react-app"
git push heroku master
```

### Visit the app's public URL in your browser

```bash
heroku open
```

### Visit the Heroku Dashboard for the app

Find the app on [your dashboard](https://dashboard.heroku.com).

### Continue Development

Work with your app locally using `npm start`. See: [create-react-app docs](https://github.com/facebookincubator/create-react-app#getting-started)

Then, commit & deploy ♻️

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
      "url": "https://github.com/mars/create-react-app-buildpack"
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

The default `static.json`, if it does not exist in the repo, is:

```json
{ "root": "build/" }
```

### Routing clean URLs

[React Router](https://github.com/ReactTraining/react-router) (not included) may easily use hash-based URLs like `https://example.com/index.html#/users/me/edit`. This is nice & easy when getting started with local development, but for a public app you probably want real URLs like `https://example.com/users/me/edit`.

Create a `static.json` file to configure the web server for clean [`browserHistory` with React Router v3](https://github.com/ReactTraining/react-router/blob/v3/docs/guides/Histories.md#browserhistory) & [`BrowserRouter` with v4](https://reacttraining.com/react-router/web/api/BrowserRouter):

```json
{
  "root": "build/",
  "routes": {
    "/**": "index.html"
  }
}
```

👓 See [custom routing w/ the static buildpack](https://github.com/heroku/heroku-buildpack-static#custom-routes).

### HTTPS-only

Enforce secure connections by automatically redirecting insecure requests to **https://**, in `static.json`:

```json
{
  "root": "build/",
  "https_only": true
}
```

Prevent downgrade attacks with [HTTP strict transport security](https://developer.mozilla.org/en-US/docs/Web/Security/HTTP_strict_transport_security). Add HSTS `"headers"` to `static.json`:

```json
{
  "root": "build/",
  "https_only": true,
  "headers": {
    "/**": {
      "Strict-Transport-Security": "max-age=7776000"
    }
  }
}
```

* `max-age` is the number of seconds to enforce HTTPS since the last connection; the example is 90-days

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

[`REACT_APP_*` environment variables](https://github.com/facebookincubator/create-react-app/blob/master/packages/react-scripts/template/README.md#adding-custom-environment-variables) are supported with this buildpack.

🤐 *Be careful not to export secrets. These values may be accessed by anyone who can see the React app.*

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

♻️ The app must be re-deployed for compiled changes to take effect.

```bash
heroku config:set REACT_APP_HELLO='I love sushi!'

git commit --allow-empty -m "Set REACT_APP_HELLO config var"
git push heroku master
```

### Runtime configuration

*Requires at least create-react-app 0.7.*

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

### Add-on config vars

🤐 *Be careful not to export secrets. These values may be accessed by anyone who can see the React app.*

Use a custom [`.profile.d` script](https://devcenter.heroku.com/articles/buildpack-api#profile-d-scripts) to make variables visible to the React app by prefixing them with `REACT_APP_`.

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

Troubleshooting
---------------

1. Confirm that your app is using this buildpack:

    ```bash
    heroku buildpacks
    ```
    
    If it's not using `create-react-app-buildpack`, then set it:

    ```bash
    heroku buildpacks:set https://github.com/mars/create-react-app-buildpack.git
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
heroku buildpacks:set https://github.com/mars/create-react-app-buildpack.git#v1.2.1
```

✏️ *Replace `v1.2.1` with the desired [release tag](https://github.com/mars/create-react-app-buildpack/releases).*

♻️ Then, commit & deploy to rebuild on the new buildpack version.


Architecture 🏙
------------

This buildpack combines several buildpacks, specified in [`.buildpacks`](.buildpacks), to support **zero-configuration deployment** on Heroku:

1. [`heroku/nodejs` buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
   * installs complete `node`, puts it on the `$PATH`
   * version specified in [`package.json`, `engines.node`](https://devcenter.heroku.com/articles/nodejs-support#specifying-a-node-js-version)
   * `node_modules/` cached between deployments
2. [`mars/create-react-app-inner-buildpack`](https://github.com/mars/create-react-app-inner-buildpack)
   * production build for create-react-app
   * generates the [default `static.json`](#user-content-web-server)
   * enables [runtime environment variables](#user-content-environment-variables)
3. [`heroku/static` buildpack](https://github.com/heroku/heroku-buildpack-static)
   * [Nginx](http://nginx.org/en/) web server
   * launches via `bin/boot`
   * configure via `static.json`; see [options specific to this buildpack](#user-content-web-server) and [all options](https://github.com/heroku/heroku-buildpack-static#configuration)

Runtime processes are launched based on the last buildpack's default processes, the static buildpack's Nginx web server. Processes may be customized with a [Procfile](#user-content-procfile).


### General-purpose SPA deployment

[Some kind feedback](https://github.com/mars/create-react-app-buildpack/issues/2) pointed out that this buildpack is not necessarily specific to `create-react-app`.

This buildpack can deploy any SPA [single-page app] as long as it meets the following requirements:

* `npm run build` performs the transpile/bundling
* the file `build/index.html` or [the root specified in `static.json`](#user-content-customization) exists at runtime.
