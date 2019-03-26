# Webdrivers

[![Gem Version](https://badge.fury.io/rb/webdrivers.svg)](https://badge.fury.io/rb/webdrivers)
[![Build status](https://api.travis-ci.org/titusfortner/webdrivers.svg)](https://travis-ci.org/titusfortner/webdrivers)

Run Selenium tests more easily with automatic installation and updates for all supported webdrivers.

# Description

`webdrivers` downloads drivers and directs Selenium to use them.

Currently supported:
* `chromedriver`
* `geckodriver`
* `IEDriverServer`
* `MicrosoftWebDriver`

Drivers are stored in `~/.webdrivers` directory, and this is configurable:
 
 ```ruby
 Webdrivers.install_dir = '/webdrivers/install/dir'
```

# Usage

In your Gemfile: 

`gem 'webdrivers', '~> 3.0'`

In your project:

```ruby
require 'webdrivers'
```

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

If you are getting an error like this (especially common on Windows)  
`SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed`

add the following to your code:

````ruby
Webdrivers.net_http_ssl_fix
````

You can also specify the webdriver versions if you don't want the latest:

```ruby
Webdrivers::Chromedriver.version = '2.46'
Webdrivers::Geckodriver.version  = '0.17.0'
Webdrivers::IEdriver.version     = '3.14.0'
Webdrivers::MSWebdriver.version  = '17134'
```

**Note when using Chrome/Chromium with Selenium**

You can configure the gem to use a specific browser version (Chrome vs Chromium) by providing the path to its binary:

```ruby
Selenium::WebDriver::Chrome.path = '/chromium/install/path'
```

**Note when using Microsoft Edge**

After updating Microsoft Edge on Windows 10, you will need to delete the existing binary (`%USERPROFILE%/.webdrivers/MicrosoftWebDriver.exe`) to
to be able to download the latest version through this gem.

This is because `MicrosoftWebDriver.exe` is not backwards compatible and it does not have an argument to retrieve 
the current version. We work around this limitation by querying the current Edge version from the registry and 
fetching the corresponding binary IF a file does not already exist. If a file does exist, the gem assumes it is the 
expected version and skips the download process.

If you continue with the outdated binary, Selenium will throw an error: `unable to connect to MicrosoftWebDriver localhost:17556`.

# License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT),
see LICENSE.txt for full details and copyright.


# Contributing

Bug reports and pull requests are welcome [on GitHub](https://github.com/titusfortner/webdrivers).


## Copyright

Copyright (c) 2017 Titus Fortner
See LICENSE for details
