# frozen_string_literal: true

require 'shellwords'
require 'webdrivers/common'
require 'webdrivers/chrome_finder'

module Webdrivers
  class Chromedriver < Common
    class << self
      #
      # Returns current chromedriver version.
      #
      # @return [Gem::Version]
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless exists?

        version = binary_version
        return nil if version.nil?

        # Matches 2.46, 2.46.628411 and 73.0.3683.75
        normalize_version version[/\d+\.\d+(\.\d+)?(\.\d+)?/]
      end

      #
      # Returns latest available chromedriver version.
      #
      # @return [Gem::Version]
      def latest_version
        @latest_version ||= begin
          # Versions before 70 do not have a LATEST_RELEASE file
          return normalize_version('2.41') if browser_build_version < normalize_version('70')

          # Cache check
          # Cached version should exist and be compatible with the current browser version.
          # Otherwise, fetch the latest compatible driver.
          latest_applicable = with_cache(file_name,
                                         current_build_version,
                                         browser_build_version) { latest_point_release(browser_build_version) }

          Webdrivers.logger.debug "Latest version available: #{latest_applicable}"
          normalize_version(latest_applicable)
        end
      end

      #
      # Returns currently installed Chrome/Chromium version.
      #
      # @return [Gem::Version]
      def browser_version
        normalize_version ChromeFinder.version
      end
      alias chrome_version browser_version

      #
      # Returns url with domain for calls to get this driver.
      #
      # @return [String]
      def base_url
        'https://chromedriver.storage.googleapis.com'
      end

      private

      def latest_point_release(version)
        if version < normalize_version('115')
          return normalize_version(Network.get(URI.join(base_url, "LATEST_RELEASE_#{version}")))
        end

        latest_patch_version(version)
      rescue NetworkError
        msg = "Unable to find latest point release version for #{version}."
        msg = begin
          latest_release = normalize_version(Network.get(URI.join(base_url, 'LATEST_RELEASE')))
          if version > latest_release
            "#{msg} You appear to be using a non-production version of Chrome."
          else
            msg
          end
        rescue NetworkError
          "#{msg} A network issue is preventing determination of latest chromedriver release."
        end

        msg = "#{msg} Please set `Webdrivers::Chromedriver.required_version = <desired driver version>` "\
                'to a known chromedriver version: https://chromedriver.chromium.org/downloads/version-selection'
        Webdrivers.logger.debug msg
        raise VersionError, msg
      end

      def file_name
        System.platform == 'win' || System.wsl_v1? ? 'chromedriver.exe' : 'chromedriver'
      end

      def apple_m1_compatible?(driver_version)
        if System.apple_m1_architecture? && driver_version >= normalize_version('87.0.4280.88')
          Webdrivers.logger.debug 'chromedriver version is Apple M1 compatible.'
          return true
        end

        Webdrivers.logger.debug 'chromedriver version is NOT Apple M1 compatible. Required >= 87.0.4280.88'
        false
      end

      def apple_filename(driver_version)
        unless apple_m1_compatible?(driver_version)
          return driver_version >= normalize_version('115') ? 'mac-x64' : 'mac64'
        end

        if driver_version < normalize_version('106.0.5249.61')
          'mac64_m1'
        elsif driver_version < normalize_version('115')
          'mac_arm64'
        else
          'mac-arm64'
        end
      end

      def direct_url(driver_version)
        direct_url_from_api(driver_version) ||
          "#{base_url}/#{driver_version}/chromedriver_#{driver_filename(driver_version)}.zip"
      end

      def driver_filename(driver_version)
        if System.platform == 'win' || System.wsl_v1?
          'win32'
        elsif System.platform == 'linux'
          'linux64'
        elsif System.platform == 'mac'
          apple_filename(driver_version)
        else
          raise 'Failed to determine driver filename to download for your OS.'
        end
      end

      # Returns major.minor.build version from the currently installed chromedriver version
      #
      # @example
      #   73.0.3683.68 (major.minor.build.patch) -> 73.0.3683 (major.minor.build)
      def current_build_version
        build_ver = if current_version.nil? # Driver not found
                      nil
                    else
                      current_version.segments[0..2].join('.')
                    end
        normalize_version(build_ver)
      end

      # Returns major.minor.build version from the currently installed Chrome version
      #
      # @example
      #   73.0.3683.75 (major.minor.build.patch) -> 73.0.3683 (major.minor.build)
      def browser_build_version
        normalize_version(browser_version.segments[0..2].join('.'))
      end

      alias chrome_build_version browser_build_version

      # Returns true if an executable driver binary exists
      # and its build version matches the browser build version
      def sufficient_binary?
        super && current_version && (current_version < normalize_version('70.0.3538') ||
          current_build_version == browser_build_version)
      end

      def chrome_for_testing_base_url
        'https://googlechromelabs.github.io/chrome-for-testing/'
      end

      def latest_patch_version(driver_version)
        latest_patch_version = URI.join(chrome_for_testing_base_url, 'latest-patch-versions-per-build.json')
                                  .then { |url| Network.get(url) }
                                  .then { |res| JSON.parse(res, symbolize_names: true) }
                                  .then { |json| json.dig(:builds, :"#{driver_version}", :version) }
                                  .then { |version| version ? normalize_version(version) : nil }
        raise NetworkError unless latest_patch_version

        latest_patch_version
      end

      def direct_url_from_api(driver_version)
        return if normalize_version(driver_version) < normalize_version('115')

        URI.join(chrome_for_testing_base_url, 'known-good-versions-with-downloads.json')
           .then { |url| Network.get(url) }
           .then { |res| JSON.parse(res, symbolize_names: true) }
           .then { |json| json[:versions].find { |e| e[:version] == driver_version.to_s } }
           .then { |json| json.dig(:downloads, :chromedriver) }
           .then { |json| json.find { |e| e[:platform] == driver_filename(driver_version) } }
           .then { |json| json&.dig(:url) }
      end
    end
  end
end

::Selenium::WebDriver::Chrome::Service.driver_path = proc { ::Webdrivers::Chromedriver.update }
