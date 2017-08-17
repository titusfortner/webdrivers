require 'selenium-webdriver'

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
