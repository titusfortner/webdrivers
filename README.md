# Webdrivers

[![Gem Version](https://badge.fury.io/rb/webdrivers.svg)](https://badge.fury.io/rb/webdrivers)
[![Build status](https://travis-ci.org/titusfortner/webdrivers.svg?branch=master)](https://travis-ci.org/titusfortner/webdrivers)
[![AppVeyor status](https://ci.appveyor.com/api/projects/status/ejh90xqbvkphq4cy/branch/master?svg=true)](https://ci.appveyor.com/project/titusfortner/webdrivers/branch/master)

Run Selenium tests more easily with automatic installation and updates for all supported webdrivers.

## Description

`webdrivers` downloads drivers and directs Selenium to use them. Currently supports:

* [chromedriver](http://chromedriver.chromium.org/)
* [geckodriver](https://github.com/mozilla/geckodriver)
* [IEDriverServer](https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver)
* [MicrosoftWebDriver](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/)

## Usage

In your Gemfile: 

`gem 'webdrivers', '~> 3.0'`

In your project:

```ruby
require 'webdrivers'
```

The drivers will now be automatically downloaded or updated when you launch a browser
through Selenium. 

### Download Location

The default download location is `~/.webdrivers` directory, and this is configurable:
 
 ```ruby
 Webdrivers.install_dir = '/webdrivers/install/dir'
```

### Version Pinning

If you would like to use a specific (older or beta) version, you can specify it for each driver. Otherwise, the latest (stable) 
driver will be downloaded and passed to Selenium.

```ruby
# Chrome
Webdrivers::Chromedriver.version = '2.46'

# Firefox
Webdrivers::Geckodriver.version  = '0.23.0'

# Microsoft Internet Explorer
Webdrivers::IEdriver.version     = '3.14.0'

# Microsoft Edge
Webdrivers::MSWebdriver.version  = '17134'
```

You can also trigger the update in your code, but it is not required:

```ruby
Webdrivers::Chromedriver.update
```

### Proxy

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

### `SSL_connect` errors

If you are getting an error like this (especially common on Windows):
 
`SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed`

Add the following to your Gemfile:

```ruby
gem "net_http_ssl_fix"
```

Add the following to your code:

````ruby
require 'net_http_ssl_fix'
````

Other solutions are documented on the RubyGems [website](https://guides.rubygems.org/ssl-certificate-update/).

### Logging

The logging level can be configured for debugging purpose:

```ruby
Webdrivers.logger.level = :DEBUG
```

### Browser Specific Notes

#### When using Chrome/Chromium

The version of `chromedriver` will depend on the version of Chrome you are using it with:

 * For versions >= 70, the downloaded version of `chromedriver` will match the installed version of Google Chrome. More information [here](http://chromedriver.chromium.org/downloads/version-selection).
 * For versions <=  69, `chromedriver` version 2.46 will be downloaded.
 * For beta versions, you'll have to set the desired beta version of `chromedriver` using `Webdrivers::Chromedriver.version`.
 
The gem, by default, looks for the Google Chrome version. You can override this by providing a path to the Chromium binary:

```ruby
Selenium::WebDriver::Chrome.path = '/chromium/install/path/to/binary'
```

This is also required if Google Chrome is not installed in its [default location](https://github.com/SeleniumHQ/selenium/wiki/ChromeDriver).

#### When using Microsoft Edge

After updating Microsoft Edge on Windows 10, you will need to delete the existing binary (`%USERPROFILE%/.webdrivers/MicrosoftWebDriver.exe`) to
to be able to download the latest version through this gem.

This is because `MicrosoftWebDriver.exe` is not backwards compatible and it does not have an argument to retrieve 
the current version. We work around this limitation by querying the current Edge version from the registry and 
fetching the corresponding binary IF a file does not already exist. If a file does exist, the gem assumes it is the 
expected version and skips the download process.

If you continue with the outdated binary, Selenium will throw an error: `unable to connect to MicrosoftWebDriver localhost:17556`.

## Wiki

Please see the [wiki](https://github.com/titusfortner/webdrivers/wiki) for solutions to commonly reported issues.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT),
see LICENSE.txt for full details and copyright.

## Contributing

Bug reports and pull requests are welcome [on GitHub](https://github.com/titusfortner/webdrivers). Run `bundle exec rake` and squash the commits in your PRs.

## Copyright

Copyright (c) 2017 Titus Fortner
See LICENSE for details
