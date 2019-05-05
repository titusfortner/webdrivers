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
        @latest_version ||= Gem::Version.new(Network.get_url("#{base_url}/latest")[/[^v]*$/])
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
