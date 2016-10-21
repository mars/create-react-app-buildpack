Heroku Buildpack for create-react-app
=====================================

Deploy React.js web apps generated with [create-react-app](https://github.com/facebookincubator/create-react-app). Automates deployment with the built-in bundler and serves it up via [Nginx](http://nginx.org/en/). See the [introductory blog post](https://blog.heroku.com/deploying-react-with-zero-configuration) and entry in [Heroku elements](https://elements.heroku.com/buildpacks/mars/create-react-app-buildpack).

* ⚠️ [Requirements](#requires)
* 🚀 [Usage](#usage)
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
* 📍 [Version compatibility](#version-compatibility)
* 🏙 [Architecture](#architecture-)
* 🔩 [Development](#development)

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

Usage
-----

### Generate a React app

```bash
create-react-app my-app
cd my-app
```

### Make it a git repo

```bash
git init
```

At this point, this new repo is local, only on your computer. Eventually, you may want to [push to Github](#push-to-github).

### Create the Heroku app

```bash
heroku create $my-app-name --buildpack https://github.com/mars/create-react-app-buildpack.git
```

✏️ *Replace `$my-app-name` with a name for your unique app.*

This command:

* sets the [app name](https://devcenter.heroku.com/articles/creating-apps#creating-a-named-app) & its URL `https://my-app-name.herokuapp.com`
* sets the [buildpack](https://devcenter.heroku.com/articles/buildpacks) to deploy a `create-react-app` app
* configures the [`heroku` remote](https://devcenter.heroku.com/articles/git#creating-a-heroku-remote) in the local git repo, so `git push heroku master` will push to this new Heroku app.

### Commit & deploy ♻️

```bash
git add .
git commit -m "react-create-app on Heroku"
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

#### Routing clean URLs

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

#### HTTPS-only

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

[`REACT_APP_*`](https://github.com/facebookincubator/create-react-app/blob/v0.2.3/template/README.md#adding-custom-environment-variables) and [`NODE_*`](https://github.com/facebookincubator/create-react-app/pull/476) environment variables are supported on Heroku during the compile phase, when `npm run build` is executed to generate the JavaScript bundle.

Set [config vars on a Heroku app](https://devcenter.heroku.com/articles/config-vars) like this:

```bash
heroku config:set REACT_APP_HELLO='I love sushi!'
```

♻️ The app must be re-deployed for this change to take effect, because the automatic restart after a config var change does not rebuild the JavaScript bundle.

```bash
git commit --allow-empty -m "Set REACT_APP_HELLO config var"
git push heroku master
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

This buildpack composes three buildpacks (specified in [`.buildpacks`](.buildpacks)) to support **no-configuration deployment** on Heroku:

1. [`heroku/nodejs` buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
  * complete Node.js enviroment to support the webpack build
  * `node_modules` cached between deployments
2. [`mars/create-react-app-inner-buildpack`](https://github.com/mars/create-react-app-inner-buildpack)
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


Development
-----------

[![Build Status](https://travis-ci.org/mars/create-react-app-buildpack.svg?branch=master)](https://travis-ci.org/mars/create-react-app-buildpack)

Create & run tests using the [Buildpack Testrunner](https://github.com/heroku/heroku-buildpack-testrunner).
