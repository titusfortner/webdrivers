require 'selenium-webdriver'

module Selenium
  module WebDriver
    module Chrome
      def self.driver_path
        @driver_path ||= Webdrivers::Chromedriver.update
      end
    end
  end
end
