Heroku Buildpack for create-react-app
=====================================

🔬🚧 This is an experimental branch to reimplement this buildpack with a pure Node server, avoiding the confusion ([1](https://github.com/mars/create-react-app-buildpack/issues/104), [2](https://github.com/mars/create-react-app-buildpack/issues/99), [3](https://github.com/mars/create-react-app-buildpack/issues/67)…) of original version caused by [using a static web server (Nginx) for the runtime](https://github.com/mars/create-react-app-buildpack/blob/master/README.md#user-content-architecture-).

In its current state, this branch will deploy a create-react-app project like the original (master branch), but is missing customization features.

Roadmap
-------

This buildpack will deploy a create-react-app project with zero-config required. All customization will be performed by the developer creating & committing their own Node [`server/index.js`](https://github.com/mars/create-react-app-buildpack/blob/pure-node/server/index.js) with code-based customizations. `static.json` will no longer have any effect on the runtime.

- [ ] Setup acceptance testing
- [ ] Support custom `server/index.js`
- [ ] Example: Routing
- [ ] Example: HTTPS-only
- [ ] Example: Proxy
- [ ] Support dynamic templates `public/index.ejs`
- [ ] Example: Runtime environment vars
- [ ] Document Procfile customization

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
heroku create $APP_NAME --buildpack https://github.com/mars/create-react-app-buildpack.git#pure-node
git add .
git commit -m "🌱 create-react-app"
git push heroku master
heroku open
```
