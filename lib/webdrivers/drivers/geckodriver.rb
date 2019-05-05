# frozen_string_literal: true

require 'nokogiri'

module Webdrivers
  class Geckodriver < Common
    class << self
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless downloaded?

        version = binary_version
        return nil if version.nil?

        normalize_version version.match(/geckodriver (\d+\.\d+\.\d+)/)[1]
      end

      def latest_version
        @latest_version ||= if System.valid_cache?(file_name)
                              normalize_version System.cached_version(file_name)
                            else
                              Webdrivers.logger.warn 'Driver caching is turned off in this version, but will '\
                              'be enabled by default in 4.x. Set the value now with `Webdrivers#cache_time=` in seconds'
                              version = normalize_version(Network.get_url("#{base_url}/latest")[/[^v]*$/])
                              System.cache_version(file_name, version)
                              version
                            end
      end

      private

      def file_name
        System.platform == 'win' ? 'geckodriver.exe' : 'geckodriver'
      end

      def base_url
        'https://github.com/mozilla/geckodriver/releases'
      end

      def download_url
        @download_url ||= required_version.version.empty? ? direct_url(latest_version) : direct_url(required_version)
      end

      def direct_url(version)
        "#{base_url}/download/v#{version}/geckodriver-v#{version}-#{platform_ext}"
      end

      def platform_ext
        case System.platform
        when 'linux'
          "linux#{System.bitsize}.tar.gz"
        when 'mac'
          'macos.tar.gz'
        when 'win'
          "win#{System.bitsize}.zip"
        end
      end
    end
  end
end
