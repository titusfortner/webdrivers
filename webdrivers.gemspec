$LOAD_PATH.push File.expand_path('../lib', __dir__)

Gem::Specification.new do |s|
  s.name        = 'webdrivers'
  s.version     = '3.7.2'
  s.authors     = ['Titus Fortner', 'Lakshya Kapoor']
  s.email       = %w[titusfortner@gmail.com kapoorlakshya@gmail.com]
  s.homepage    = 'https://github.com/titusfortner/webdrivers'
  s.summary     = 'Easy download and use of browser drivers.'
  s.description = 'Run Selenium tests more easily with install and updates for all supported webdrivers.'
  s.licenses    = ['MIT']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~>0.66'
  s.add_development_dependency 'rubocop-rspec', '~>1.32'
  s.add_development_dependency 'simplecov', '~>0.16'

  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'rubyzip', '~> 1.0'
  s.add_runtime_dependency 'selenium-webdriver', '~> 3.0'
end
