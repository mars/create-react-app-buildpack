Heroku Buildpack for create-react-app
=====================================

Deploy React.js web apps generated with [create-react-app](https://github.com/facebookincubator/create-react-app).

> Automates deployment with the built-in tooling and serves it up via [Nginx](http://nginx.org/en/).

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
heroku create my-app-name --buildpack https://github.com/mars/create-react-app-buildpack.git
```

✏️ *Replace `my-app-name` with a name for your unique app.*

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

### Environment variables

Set [config vars on a Heroku app](https://devcenter.heroku.com/articles/config-vars) like this:

```bash
heroku config:set REACT_APP_HELLO='I love sushi!'
```

#### Compile-time configuration

For variables that will not change between environments, such as:

  * version number
  * commit sha or number
  * browser support flags

[`REACT_APP_*`](https://github.com/facebookincubator/create-react-app/blob/v0.2.3/template/README.md#adding-custom-environment-variables) and [`NODE_*`](https://github.com/facebookincubator/create-react-app/pull/476) environment variables are supported on Heroku during the compile phase, when `npm run build` is executed to generate the JavaScript bundle.

♻️ The app must be re-deployed for compiled changed to take effect, because the automatic restart after a config var change does not rebuild the JavaScript bundle.

```bash
git commit --allow-empty -m "Set REACT_APP_HELLO config var"
git push heroku master
```

#### Runtime configuration

For variables that may change between releases or environments:

  * Heroku add-on config vars
  * URLs to APIs
  * secret tokens

Any environment variable is accessible at runtime, not just `REACT_APP_*`.

Add script element to `index.html` to capture environment variable values:

```html
  <head>
    <!-- Existing head elements come first -->
    <script type="text/javascript">
      react_app_env = {};
      react_app_env.HELLO = '{{REACT_APP_HELLO}}';
    </script>
  </head>
```

Then, use these globals within the React app.

```javascript
const hello = react_app_env.HELLO;
```

Globals are normally considered dirty, so you may build up a more acceptable pattern for using these values in an app, such as:

* create a module to read the global values and make them available via `require`
* create a [higher order component [HOC]](https://medium.com/@dan_abramov/mixins-are-dead-long-live-higher-order-components-94a0d2f9e750) that makes the values available via props

Version compatibility
---------------------

We'll keep branches to maintain compatibility as `create-react-app` evolves. These will only be useful for projects that have been ejected and therefore stagnate with the tooling of a specific version.

Currently, using branch `cra-0.2.x` will ensure that your deployment continues to work with 0.2.x versions of `create-react-app`.

```bash
heroku create -b https://github.com/mars/create-react-app-buildpack.git#cra-0.2.x
```

Usually, using master [as directed in the main instructions](#create-the-heroku-app) will be appropriate to automatically keep up with the newest `create-react-app`.


Architecture 🏙
------------

This buildpack composes several buildpacks (specified in [`.buildpacks`](.buildpacks)) to support **no-configuration deployment** on Heroku:

1. [`heroku/nodejs` buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
  * complete Node.js enviroment to support the webpack build
  * `node_modules` cached between deployments
2. [`mars/create-react-app-inner-buildpack`](https://github.com/mars/create-react-app-inner-buildpack)
  * generates the default `mustache_templates.conf`
  * generates the [default `static.json`](#customization)
  * performs the production build for create-react-app, `npm run build`
3. [`heroku/heroku-buildpack-mustache`](https://github.com/heroku/heroku-buildpack-mustache)
  * performs [runtime replacement of environment variables](#runtime-configuration)
4. [`heroku/static` buildpack](https://github.com/heroku/heroku-buildpack-static)
  * [Nginx](http://nginx.org/en/) web server
  * handy static website & SPA (single-page app) [customization options](https://github.com/heroku/heroku-buildpack-static#configuration)


### General-purpose SPA deployment

[Some kind feedback](https://github.com/mars/create-react-app-buildpack/issues/2) pointed out that this buildpack is not necessarily specific to `create-react-app`.

This buildpack can deploy any SPA [single-page app] as long as it meets the following requirements:

* `npm run build` performs the transpile/bundling
* the file `build/index.html` or [the root specified in `static.json`](#customization) exists at runtime.
