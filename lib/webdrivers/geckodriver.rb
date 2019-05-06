# frozen_string_literal: true

require 'nokogiri'
require 'webdrivers/common'

module Webdrivers
  class Geckodriver < Common
    class << self
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless exists?

        string = `#{binary} --version`
        Webdrivers.logger.debug "Current version of #{binary} is #{string}"
        normalize_version string.match(/geckodriver (\d+\.\d+\.\d+)/)[1]
      end

      private

      def downloads # rubocop:disable  Metrics/AbcSize
        doc = Nokogiri::HTML.parse(get(base_url))
        items = doc.css('.py-1 a').collect { |item| item['href'] }
        items.reject! { |item| item.include?('archive') }
        items.select! { |item| item.include?(platform) }
        ds = items.each_with_object({}) do |item, hash|
          key = normalize_version item[/v(\d+\.\d+\.\d+)/, 1]
          hash[key] = "https://github.com#{item}"
        end
        Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
        ds
      end

      def file_name
        platform == 'win' ? 'geckodriver.exe' : 'geckodriver'
      end

      def base_url
        'https://github.com/mozilla/geckodriver/releases'
      end
    end
  end
end

if ::Selenium::WebDriver::Service.respond_to? :driver_path=
  ::Selenium::WebDriver::Firefox::Service.driver_path = proc { ::Webdrivers::Geckodriver.update }
else
  # v3.141.0 and lower
  module Selenium
    module WebDriver
      module Firefox
        def self.driver_path
          @driver_path ||= Webdrivers::Geckodriver.update
        end
      end
    end
  end
end
