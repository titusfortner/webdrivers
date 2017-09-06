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

`require 'webdrivers'

If there is a proxy between you and the Internet then you will need to configure
the gem to use the proxy.  You can do this by calling the `configure` method.

````ruby
Webdrivers.configure do |config|
  config.proxy_addr = 'myproxy_address.com'
  config.proxy_port = '8080'
  config.proxy_user = 'username'
  config.proxy_pass = 'password'
end
````

# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT), 
see LICENSE.txt for full details and copyright.


# Contributing

Bug reports and pull requests are welcome [on GitHub](https://github.com/titusfortner/webdrivers).


## Copyright

Copyright (c) 2017 Titus Fortner
See LICENSE for details
