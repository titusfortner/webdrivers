# frozen_string_literal: true

require 'webdrivers/common'

module Webdrivers
  class MSWebdriver
    class << self
      attr_accessor :ignore
    end
  end
end

module Selenium
  module WebDriver
    module Edge
      if defined?(Selenium::WebDriver::VERSION) && Selenium::WebDriver::VERSION > '3.141.0'
        class Service < WebDriver::Service
          class << self
            alias se_driver_path driver_path

            def driver_path
              unless Webdrivers::MSWebdriver.ignore
                Webdrivers.logger.warn 'Microsoft WebDriver for the Edge browser is no longer supported by Webdrivers'\
          ' gem. Due to changes in Edge implementation, the correct version can no longer be accurately provided. '\
          'Download driver, and specify the location with `Selenium::WebDriver::Edge.driver_path = "/driver/path"`, '\
          'or place it in PATH Environment Variable. '\
          'Download directions here: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/#downloads '\
          'To remove this warning in Webdrivers 3.x, set `Webdrivers.MSWebdriver.ignore`'
              end

              se_driver_path
            end
          end
        end
      else
        class << self
          alias se_driver_path driver_path

          def driver_path
            unless Webdrivers::MSWebdriver.ignore
              Webdrivers.logger.warn 'Microsoft WebDriver for the Edge browser is no longer supported by Webdrivers'\
          ' gem. Due to changes in Edge implementation, the correct version can no longer be accurately provided. '\
          'Download driver, and specify the location with `Selenium::WebDriver::Edge.driver_path = "/driver/path"`, '\
          'or place it in PATH Environment Variable. '\
          'Download directions here: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/#downloads '\
          'To remove this warning in Webdrivers 3.x, set `Webdrivers.MSWebdriver.ignore`'
            end

            se_driver_path
          end
        end
      end
    end
  end
end
