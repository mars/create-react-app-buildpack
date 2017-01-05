Heroku Buildpack for create-react-app
=====================================

Deploy React.js web apps generated with [create-react-app](https://github.com/facebookincubator/create-react-app). Automates deployment with the built-in bundler and serves it up via [Nginx](http://nginx.org/en/). See the [introductory blog post](https://blog.heroku.com/deploying-react-with-zero-configuration) and entry in [Heroku elements](https://elements.heroku.com/buildpacks/mars/create-react-app-buildpack).

* ⚠️ [Requirements](#requires)
* 🚀 [Quick Start](#quick-start)
* [Usage](#usage)
  1. [Generate a React app](#generate-a-react-app)
  1. [Make it a git repo](#make-it-a-git-repo)
  1. [Create the Heroku app](#create-the-heroku-app)
  1. [Commit & deploy ♻️](#commit--deploy-️)
  1. [Continue Development](#continue-development)
* 👓 [Customization](#customization)
  * [Web server](#web-server)
    * [Routing clean URLs](#routing-clean-urls)
    * [HTTPS-only](#https-only)
  * [Environment variables](#environment-variables)
    * [Set vars on Heroku](#set-vars-on-heroku)
    * [Set vars for local dev](#set-vars-for-local-dev)
    * [Compile-time vs Runtime](#compile-time-vs-runtime)
      * [Compile-time config](#compile-time-configuration)
      * [Runtime config](#runtime-configuration)
    * [using an Add-on's config](#add-on-config-vars)
* 📍 [Version compatibility](#version-compatibility)
* 🏙 [Architecture](#architecture-)

-----

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

Ensure [requirements](#requires) are met, then execute the following in a terminal.

✏️ *Replace `$APP_NAME` with a name for your unique app.*

```bash
create-react-app $APP_NAME
cd $APP_NAME
git init
heroku create $APP_NAME --buildpack https://github.com/mars/create-react-app-buildpack.git
git add .
git commit -m "Start with create-react-app"
git push heroku master
heroku open
```

For explanation about these steps, continue reading the next section.

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

At this point, this new repo is local, only on your computer. Eventually, you may want to [push to Github](#push-to-github).

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


Customization
-------------

### Web server

The web server may be [configured via the static buildpack](https://github.com/heroku/heroku-buildpack-static#configuration).

The default `static.json`, if it does not exist in the repo, is:

```json
{ "root": "build/" }
```

### Routing clean URLs

By default, [React Router](https://github.com/reactjs/react-router) (not included) uses hash-based URLs like `https://example.com/index.html#/users/me/edit`. This is nice & easy when getting started with local development, but for a public app you probably want real URLs like `https://example.com/users/me/edit`.

Create a `static.json` file to configure the web server for clean [`browserHistory` URLs with React Router](https://github.com/reactjs/react-router/blob/master/docs/guides/Histories.md#browserhistory):

```json
{
  "root": "build/",
  "clean_urls": false,
  "routes": {
    "/**": "index.html"
  }
}
```

### HTTPS-only

Enforce secure connections by automatically redirecting insecure requests to **https://**, in `static.json`:

```json
{
  "https_only": true
}
```

Prevent downgrade attacks with [HTTP strict transport security](https://developer.mozilla.org/en-US/docs/Web/Security/HTTP_strict_transport_security). Add HSTS `"headers"` to `static.json`:

```json
{
  "headers": {
    "/**": {
      "Strict-Transport-Security": "max-age=7776000"
    }
  }
}
```

* `max-age` is the number of seconds to enforce HTTPS since the last connection; the example is 90-days

### Environment variables

[`REACT_APP_*` environment variables](https://github.com/facebookincubator/create-react-app/blob/v0.2.3/template/README.md#adding-custom-environment-variables) are supported with this buildpack.

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

Requirement | [Compile-time](#compile-time-configuration) | [Runtime](#runtime-configuration)
:--- |:---:|:---: 
never changes for a build | ✓ |  
support for [continuous delivery](https://www.heroku.com/continuous-delivery) |  | ✓
updates immediately when setting new [config vars](https://devcenter.heroku.com/articles/config-vars) |   | ✓
different values for staging & production (in a [pipeline](https://devcenter.heroku.com/articles/pipelines)) |   | ✓
ex: `REACT_APP_BUILD_VERSION` (static fact about the bundle) | ✓ | 
ex: `REACT_APP_DEBUG_ASSERTIONS` ([prune code from bundle](https://webpack.github.io/docs/list-of-plugins.html#defineplugin)) | ✓ | 
ex: `REACT_APP_API_URL` (transient, external reference) |   | ✓
ex: `REACT_APP_FILEPICKER_API_KEY` ([Add-on config vars](#add-on-config-vars)) |   | ✓

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
1. set-up & use [Runtime configuration](#runtime-configuration) to access the variables

For example, to use the API key for the [Filestack](https://elements.heroku.com/addons/filepicker) JS image uploader:

```bash
export REACT_APP_FILEPICKER_API_KEY=${FILEPICKER_API_KEY:-}
```

Version compatibility
---------------------

This buildpack will never intentionally cause previously deployed apps to become undeployable. Using master [as directed in the main instructions](#create-the-heroku-app) will always deploy an app with the most recent version of this buildpack.

[Releases are tagged](https://github.com/mars/create-react-app-buildpack/releases), so you can lock an app to a specific version, if that kind of determinism pleases you:

```bash
heroku buildpacks:set https://github.com/mars/create-react-app-buildpack.git#v1.2.1
```

✏️ *Replace `v1.2.1` with the desired [release tag](https://github.com/mars/create-react-app-buildpack/releases).*

♻️ Then, commit & deploy to rebuild on the new buildpack version.


Architecture 🏙
------------

This buildpack composes several buildpacks (specified in [`.buildpacks`](.buildpacks)) to support **no-configuration deployment** on Heroku:

1. [`heroku/nodejs` buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
  * complete Node.js enviroment to support the webpack build
  * `node_modules` cached between deployments
2. [`mars/create-react-app-inner-buildpack`](https://github.com/mars/create-react-app-inner-buildpack)
  * enables [runtime environment variables](#runtime-configuration)
  * generates the [default `static.json`](#customization)
  * performs the production build for create-react-app, `npm run build`
3. [`heroku/static` buildpack](https://github.com/heroku/heroku-buildpack-static)
  * [Nginx](http://nginx.org/en/) web server
  * handy static website & SPA (single-page app) [customization options](https://github.com/heroku/heroku-buildpack-static#configuration)


### General-purpose SPA deployment

[Some kind feedback](https://github.com/mars/create-react-app-buildpack/issues/2) pointed out that this buildpack is not necessarily specific to `create-react-app`.

This buildpack can deploy any SPA [single-page app] as long as it meets the following requirements:

* `npm run build` performs the transpile/bundling
* the file `build/index.html` or [the root specified in `static.json`](#customization) exists at runtime.
