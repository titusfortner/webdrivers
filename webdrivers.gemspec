# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'webdrivers/version'

Gem::Specification.new do |s|
  s.name        = 'webdrivers'
  s.version     = Webdrivers::VERSION
  s.required_ruby_version = '>= 2.6.0'
  s.authors     = ['Titus Fortner', 'Lakshya Kapoor', 'Thomas Walpole']
  s.email       = %w[titusfortner@gmail.com kapoorlakshya@gmail.com]
  s.homepage    = 'https://github.com/titusfortner/webdrivers'
  s.summary     = 'Easy download and use of browser drivers.'
  s.description = 'Run Selenium tests more easily with install and updates for all supported webdrivers.'
  s.licenses    = ['MIT']

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/titusfortner/webdrivers/issues',
    'changelog_uri' => 'https://github.com/titusfortner/webdrivers/blob/master/CHANGELOG.md',
    'documentation_uri' => "https://www.rubydoc.info/gems/webdrivers/#{Webdrivers::VERSION}",
    'source_code_uri' => "https://github.com/titusfortner/webdrivers/tree/v#{Webdrivers::VERSION}"
  }

  s.files         = Dir['lib/**/*'] + %w[CHANGELOG.md LICENSE.txt README.md]
  s.test_files    = Dir['spec/**/*'].reject { |f| File.directory?(f) }
  s.executables   = []
  s.require_paths = ['lib']

  s.add_development_dependency 'ffi', '~> 1.0' # For selenium-webdriver on Windows
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 0.89'
  s.add_development_dependency 'rubocop-packaging', '~> 0.5.0'
  s.add_development_dependency 'rubocop-performance'
  s.add_development_dependency 'rubocop-rspec', '~> 1.42'
  s.add_development_dependency 'simplecov', '~> 0.16'

  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  s.add_runtime_dependency 'rubyzip', '>= 1.3.0'
  s.add_runtime_dependency 'selenium-webdriver', '~> 4.0', '< 4.11'

  s.post_install_message = <<~ENDBANNER
    Webdrivers gem update options
    *****************************

    Selenium itself now manages drivers by default: https://www.selenium.dev/documentation/selenium_manager
    * If you are using Ruby 3+ — please update to Selenium 4.11+ and stop requiring this gem
    * If you are using Ruby 2.6+ and Selenium 4.0+ — this version will work for now
    * If you use Ruby < 2.6 or Selenium 3, a 6.0 version of this gem with additional support is planned

    Restrict your gemfile to "webdrivers", "= 5.3.0" to stop seeing this message
  ENDBANNER
end
