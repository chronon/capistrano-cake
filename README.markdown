capistrano-cake
===============

Capistrano is a wonderful tool for deployment. Making it work the way I wanted it to for my specific
website and server configurations lead me to creating a deploy.rb that works exactly as I want. It's
biased for CakePHP deployment, but can work for non Cake deployments as well.

* Supports compiling and uploading css using [compass](http://compass-style.org/).
* Supports compiling and uploading js using [jammit](http://documentcloud.github.io/jammit/).
* Support installing and updating packages using [composer](http://getcomposer.org/) and
  [packagist](https://packagist.org/) 