### 3.8.0 (2019-04-17)
* Add support for `selenium-webdriver` v4. See [#69](https://github.com/titusfortner/webdrivers/pull/69).
* Remove dependency on `net_http_ssl_fix` gem. `Webdrivers.net_http_ssl_fix` now raises an exception and points to other solutions. See [#60](https://github.com/titusfortner/webdrivers/pull/60) and [#68](https://github.com/titusfortner/webdrivers/pull/68).

### 3.7.2 (2019-04-01)
* Fix bugs in methods that retrieve Chrome/Chromium version. See [#43](https://github.com/titusfortner/webdrivers/pull/43) and [#52](https://github.com/titusfortner/webdrivers/issues/52).
* Add workaround for a Jruby bug when retrieving Chrome version on Windows. See [#41](https://github.com/titusfortner/webdrivers/issues/41).
* Update README with more information.

### 3.7.1 (2019-03-25)
* Use `Selenium::WebDriver::Chrome#path` to check for a user given browser executable before defaulting to Google Chrome. Addresses [#38](https://github.com/titusfortner/webdrivers/issues/38).
* Download `chromedriver` v2.46 if Chrome/Chromium version is less than 70.

### 3.7.0 (2019-03-19)

* `chromedriver` version now matches the installed Chrome version. See [#32](https://github.com/titusfortner/webdrivers/pull/32).

### 3.6.0 (2018-12-30)

* Put net_http_ssl_fix inside a toggle since it can cause other issues

### 3.5.2 (2018-12-16)

* Use net_http_ssl_fix to address Net::HTTP issues on windows

### 3.5.1 (2018-12-16)

### 3.5.0 (2018-12-15)

### 3.5.0.beta1 (2018-12-15)

* Allow version to be specified

### 3.4.3 (2018-10-22)

* Fix bug with JRuby and geckodriver (thanks twalpole)

### 3.4.2 (2018-10-15)

* Use chromedriver latest version 

### 3.4.1 (2018-09-17)

* Hardcode latest chromedriver version to 2.42 until we figure out chromedriver 70 

### 3.4.0 (2018-09-07)

* Allow public access to `#install_dir` and `#binary`
* Allow user to set the default download directory
* Improve version comparisons with use of `Gem::Version` 

### 3.3.3 (2018-08-14)

* Fix Geckodriver since Github changed its html again

### 3.3.2 (2018-05-04)

* Fix bug with IEDriver versioning (Thanks Aleksei Gusev)

### 3.3.1 (2018-05-04)

* Fix bug with MSWebdriver to fetch the correct driver instead of latest (Thanks kapoorlakshya) 

### 3.3.0 (2018-04-29)

* Ensures downloading correct MSWebdriver version (Thanks kapoorlakshya) 

### 3.2.4 (2017-01-04)

* Improve error message when unable to find the latest driver

### 3.2.3 (2017-12-12)

* Fixed bug with finding geckodriver on updated Github release pages

### 3.2.2 (2017-11-20)

* Fixed bug in `#untargz_file` (thanks Jake Goulding)

### 3.2.1 (2017-09-06)

* Fixed Proxy support so it actually works (thanks Cheezy) 

### 3.2.0 (2017-08-21)

* Implemented Proxy support 

### 3.1.0 (2017-08-21)

* Implemented Logging functionality 

### 3.0.1 (2017-08-18)

* Create ~/.webdrivers directory if doesn't already exist 

### 3.0.0 (2017-08-17)

* Removes unnecessary downloads 

### 3.0.0.beta3 (2017-08-17)

* Supports Windows
* Supports mswebdriver and iedriver

### 3.0.0.beta2 (2017-08-16)

* Supports geckodriver on Mac and Linux

### 3.0.0.beta1 (2017-08-15)

* Complete Rewrite of 2.x
* Implemented with Monkey Patch not Shims
* Supports chromedriver on Mac and Linux
