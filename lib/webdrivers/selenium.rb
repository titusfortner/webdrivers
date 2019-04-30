# frozen_string_literal: true

require 'selenium-webdriver'

# v3.151.59 and higher
if ::Selenium::WebDriver::Service.respond_to? :driver_path=
  ::Selenium::WebDriver::Chrome::Service.driver_path  = proc { ::Webdrivers::Chromedriver.update }
  ::Selenium::WebDriver::Firefox::Service.driver_path = proc { ::Webdrivers::Geckodriver.update }
  ::Selenium::WebDriver::Edge::Service.driver_path    = proc { ::Webdrivers::MSWebdriver.update }
  ::Selenium::WebDriver::IE::Service.driver_path      = proc { ::Webdrivers::IEdriver.update }
else
  # v3.141.0 and lower
  module Selenium
    module WebDriver
      module Chrome
        def self.driver_path
          @driver_path ||= Webdrivers::Chromedriver.update
        end
      end

      module Firefox
        def self.driver_path
          @driver_path ||= Webdrivers::Geckodriver.update
        end
      end

      module Edge
        def self.driver_path
          @driver_path ||= Webdrivers::MSWebdriver.update
        end
      end

      module IE
        def self.driver_path
          @driver_path ||= Webdrivers::IEdriver.update
        end
      end
    end
  end
end
