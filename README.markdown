Deploying with Capistrano: CakePHP, Composer, and Compass
=========================================================

[Capistrano](https://github.com/capistrano/capistrano), originally developed to deploy Rails
websites, is an extremely useful tool for deploying anything. I'm using it to deploy CakePHP based
sites which use [Composer](http://getcomposer.org/) to manage dependencies,
[Compass](http://compass-style.org/) and [sass](http://sass-lang.com/) for css, and
[jammit](http://documentcloud.github.io/jammit/) for javascript compiling and minifying. Getting
everything wired together involved some work, but it was well worth the effort. I decided not to use
the fully featured [capcake](https://github.com/jadb/capcake) gem, primarily because I wanted to fine
tune the deployment for my configuration and fully understand each step.

The deployment script is available on GitHub as [capistrano-cake](https://github.com/chronon/capistrano-cake).

Installation
------------

I use [rvm](https://rvm.io/) to manage ruby on OS X, but it doesn't really matter how you do it as
long as you can install ruby gems. 

```sh
gem install capistrano
gem install railsless-deploy
```

The [railsless-deploy](https://github.com/leehambley/railsless-deploy/) gem removes most of the
*railsisms* that come with capistrano. 

The Setup
---------

I usually use a shared CakePHP core on my production servers, so deployment from development
consists of transferring my app files and dependencies (plugins, etc.). Managing dependencies with
[Composer](http://getcomposer.org/) is well worth the effort, and allows you to easily add packages
from [Packagist](https://packagist.org/) or from your own private repositories. 

My app to deploy is structured like this:

	Capfile
	composer.json
	Config/
	Console/
	Controller/
	Lib/
	Locale/
	Model/
	Plugin/
	Test/
	Vendor/
	View/
	compass/
	tmp/
	webroot/

I'm splitting up my deploy script into two files, `app.rb` and `deploy.rb`. This lets me reuse 
`deploy.rb` for every CakePHP deployment, while only changing a few variables in `app.rb`. Both of
these files are put in my app's `Config` directory. The `Capfile` in the root of my app simply loads
things:

```ruby
require 'rubygems'
require 'railsless-deploy'
load	'Config/app'
load    'Config/deploy'
```

In `Config/app.rb`, I set the required variables for deployment:

```ruby
set :application, "testapp.chronon.us"
set :repository,  "ssh://git.chronon.us/home/repos/testapp"
set :deploy_to, "/var/www/#{application}"
set :branch, "master"
role :web, "server.chronon.us"
```

The deploy strategy here is that I'm developing the site locally, pushing changes to a private git
repository (git.chronon.us), and have the production server (server.chronon.us) pull changes from
the git repository.

Deploying
---------

With my `app.rb` configured, I can set things up on the remote server:

```sh
cap deploy:setup
```

This creates two directories on the remove server, `releases` and `shared`. In `shared`, the
following directories are created by the CakePHP `deploy.rb` specifically for a CakePHP app and
permissions are set correctly for the `tmp` directory.
	
	tmp/
	Config/
	Plugin/
	Vendor/

The config files `core.php`, `bootstrap.php`, and `database.php` are uploaded to `shared/Config`.
Before deploying, make the necessary changes to these to match your production server environment.

To deploy an app for the first time:

```sh
cap deploy -S composer=install
```

The `-S composer=install` part passes the `install` command to the composer task in the deploy script.
By default, composer runs the `update` command, so future deployments will require only `cap deploy`. 

Upon deployment, a few special things happen:

* The `tmp`, `Plugin`, and `Vendor` directories in the app directory on the server are removed, and
  symlinked to the corresponding directories in the `shared` directory capistrano made.

* The files `core.php`, `bootstrap.php`, and `database.php` in the `Config` directory are removed,
  and symlinked to corresponding names in the `shared/Config` directory.

* The CakePHP tmp directory structure (cache, sessions, tests, logs) is created in `shared/tmp`.

* If a `composer.json` project file exists, composer runs `install`, putting plugins into
  `shared/Plugins` and vendor files into `shared/Vendor`.

* If a compass project exists and `set :compile_css, true` has been set in `app.rb`, the command
  `compass compile compass` is run **locally**. The compiled css files are then transferred to the
  remote server, eliminating the need to compile assets on a production server.

* If javascript compilation and minification has been configured with jammit and `set :compile_js, true` 
  has been set in `app.rb`, the command `jammit -c compass/assets.yml -o webroot/js/` runs
  **locally**. The compiled js files are then transferred to the remote server.

Options
-------

A few other variables can be set in `app.rb`, all are optional:

```ruby
set :cake_config_files, %w{core.php database.php bootstrap.php} # these are the defaults if not set
set :cake_shared_dirs, %w{tmp Vendor Plugin} # these are the defaults if not set
set :upload_dirs, %w{img/contents img/options files/downloads}
set :upload_children, %w{ img/contents/thumbs } # subdirectories created under upload_dirs
set :compile_css, true
set :compile_js, true
set :files_to_remove, %w{webroot/css/cake*.css webroot/img/cake.* webroot/img/test-*.png webroot/test.php}
```

* `cake_config_files`: the config files to symlink and upload during initial setup.
* `cake_shared_dirs`: the directories to symlink from app to shared.
* `upload_dirs`: sets the listed directories to be created in the `shared` directory and
symlinked, just like `Plugin` and `Vendor`. 
* `compile_css`: runs compass compile, requires compass to be set up in your app's `compass`
  directory.
* `compile_js`: runs jammit, requires an `assets.yml` file in your app's `compass` directory.
* `files_to_remove`: array of files to delete at the end of deployment.

Conclusion
----------

Obviously this setup is pretty specific to how I have things set up for development. Hopefully all
or at least parts of the workflow and script can helpful in deploying CakePHP sites with capistrano.
