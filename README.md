# chromedriver-helper

Easy installation and use of chromedriver, the Chromium project's
selenium webdriver adapter.

* http://github.com/flavorjones/chromedriver-helper

# Description

`chromedriver-helper` installs a script, `chromedriver`, in your gem
path. This script will, if necessary, download the appropriate binary
for your platform and install it into `~/.chromedriver`, then it will
exec the real `chromedriver`. Easy peasy!

# Credit

The idea for this gem was taken from @brianhempel's project
`chromedriver-gem` which, despite the name, is not currently published
on http://rubygems.org/.

Some improvements on that idea were taken from the installation
process for standalone passenger (mod_rails).
