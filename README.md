# Webdrivers

[![Build status](https://api.travis-ci.org/titusfortner/webdrivers.svg)](https://travis-ci.org/titusfortner/webdrivers)

Run Selenium tests more easily with automatic installation and updates for all supported webdrivers.

# Description

`webdrivers` installs driver executables, in your gem path.

Currently supported:
* `chromedriver`
* `geckodriver`
* `phantomjs`
* `IEDriverServer`
* `MicrosoftWebDriver`

Drivers are stored in `~/.webdrivers/platform` directory and used within the context of your gem path


# Usage

`gem install webdrivers`

or in your Gemfile: 

`gem "webdrivers", "~> 2.3"`


# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT), 
see LICENSE.txt for full details and copyright.


# Contributing

Bug reports and pull requests are welcome [on GitHub](https://github.com/titusfortner/webdrivers).


# Credit

This is a fork of [chromedriver-helper](https://github.com/flavorjones/chromedriver-helper) gem
