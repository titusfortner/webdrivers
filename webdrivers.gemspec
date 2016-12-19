# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "webdrivers"
  s.version     = "2.4.0"
  s.authors     = ["Titus Fortner"]
  s.email       = ["titusfortner@gmail.com"]
  s.homepage    = "https://github.com/titusfortner/webdrivers"
  s.summary     = "Easy installation and use of webdrivers."
  s.description = "Run Selenium tests more easily with install and updates for all supported webdrivers."
  s.licenses    = ["MIT"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec",   "~> 3.0"
  s.add_development_dependency "rake",    "~> 10.0"

  s.add_runtime_dependency "nokogiri",    "~> 1.6"
  s.add_runtime_dependency "rubyzip",     "~> 1.0"
end
