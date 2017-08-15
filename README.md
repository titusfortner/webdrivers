# Webdrivers

[![Build status](https://api.travis-ci.org/titusfortner/webdrivers.svg)](https://travis-ci.org/titusfortner/webdrivers)

Run Selenium tests more easily with automatic installation and updates for all supported webdrivers.

# Description

`webdrivers` downloads drivers and directs Selenium to use them.

Currently supported:
* `chromedriver`
* `geckodriver`
* `IEDriverServer`
* `MicrosoftWebDriver`

Drivers are stored in `~/.webdrivers` directory

# Usage

in your Gemfile: 

`gem "webdrivers", "~> 3.0"`

in your project:

`require 'webdrivers'`

# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT), 
see LICENSE.txt for full details and copyright.


# Contributing

Bug reports and pull requests are welcome [on GitHub](https://github.com/titusfortner/webdrivers).


## Copyright

Copyright (c) 2017 Titus Fortner
See LICENSE for details
