# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "chromedriver/helper/version"

Gem::Specification.new do |s|
  s.name        = "chromedriver-helper"
  s.version     = Chromedriver::Helper::VERSION
  s.authors     = ["Mike Dalessio"]
  s.email       = ["mike@csa.net"]
  s.homepage    = ""
  s.summary     = "Easy installation and use of chromedriver, the Chromium project's selenium webdriver adapter."
  s.description = <<EOF
`chromedriver-helper` installs a script, `chromedriver`, in your gem
path. This script will, if necessary, download the appropriate binary
for your platform and install it into `~/.chromedriver-helper`, then
it will exec the real `chromedriver`. Easy peasy!
EOF

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_runtime_dependency "nokogiri"
end
