Heroku Buildpack for create-react-app
=====================================

Deploy React.js web apps generated with [create-react-app](https://github.com/facebookincubator/create-react-app).

> Automates deployment with the built-in tooling and serves it up via [Nginx](https://www.nginx.com).

Requires
--------

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

### Create the Heroku app

Requires the [command-line tools](https://toolbelt.heroku.com) & [a free account](https://signup.heroku.com) from Heroku.

```bash
heroku create -b https://github.com/mars/create-react-app-buildpack.git
```

### Commit & deploy ♻️

```bash
git add .
git commit -m "react-create-app on Heroku"
git push heroku master
```

### Visit the live React app in your browser

```bash
heroku open
```

### Continue Development

Work with your app locally using `npm start`. See: [create-react-app docs](https://github.com/facebookincubator/create-react-app#getting-started)

Then, commit & deploy ♻️
