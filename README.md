# chromedriver-helper

Easy installation and use of chromedriver, the Chromium project's
selenium webdriver adapter.

* [http://github.com/flavorjones/chromedriver-helper](http://github.com/flavorjones/chromedriver-helper)


# Description

`chromedriver-helper` installs an executable, `chromedriver`, in your
gem path.

This script will, if necessary, download the appropriate binary for
your platform and install it into `~/.chromedriver-helper`, then exec
it. Easy peasy!

chromedriver is fast. By my unscientific benchmark, it's around 20%
faster than webdriver + Firefox 8. You should use it!


# Usage

If you're using Bundler and Capybara, it's as easy as:

    # Gemfile
    gem "chromedriver-helper"

then, in your specs:

    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome)
    end


# Support

The code lives at [http://github.com/flavorjones/chromedriver-helper](http://github.com/flavorjones/chromedriver-helper). Open a Github Issue, or send a pull request! Thanks! You're the best.


# License

(The MIT License)

Copyright (c) 2011: [Mike Dalessio](http://mike.daless.io)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Credit

The idea for this gem comes from @brianhempel's project
`chromedriver-gem` which, despite the name, is not currently published
on http://rubygems.org/.

Some improvements on the idea were taken from the installation process
for standalone Phusion Passenger.
