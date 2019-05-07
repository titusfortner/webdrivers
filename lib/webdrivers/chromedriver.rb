# frozen_string_literal: true

require 'shellwords'
require 'webdrivers/common'

module Webdrivers
  class Chromedriver < Common
    class << self
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless exists?

        version = binary_version
        return nil if version.nil?

        # Matches 2.46, 2.46.628411 and 73.0.3683.75
        normalize_version version[/\d+\.\d+(\.\d+)?(\.\d+)?/]
      end

      def latest_version
        @latest_version ||= begin
          # Versions before 70 do not have a LATEST_RELEASE file
          return normalize_version('2.41') if release_version < normalize_version('70')

          latest_applicable = latest_point_release(release_version)

          Webdrivers.logger.debug "Latest version available: #{latest_applicable}"
          normalize_version(latest_applicable)
        end
      end

      # Returns currently installed Chrome version
      def chrome_version
        ver = send("chrome_on_#{platform}").chomp

        raise VersionError, 'Failed to find Chrome binary or its version.' if ver.nil? || ver.empty?

        Webdrivers.logger.debug "Browser version: #{ver}"
        normalize_version ver[/\d+\.\d+\.\d+\.\d+/] # Google Chrome 73.0.3683.75 -> 73.0.3683.75
      end

      private

      def latest_point_release(version)
        release_file = "LATEST_RELEASE_#{version}"
        begin
          normalize_version(get(URI.join(base_url, release_file)))
        rescue (Net::HTTPClientException rescue Net::HTTPServerException) # rubocop:disable Style/RescueModifier,Naming/RescuedExceptionsVariableName
          latest_release = normalize_version(get(URI.join(base_url, 'LATEST_RELEASE')))
          Webdrivers.logger.debug "Unable to find a driver for: #{version}"

          msg = version > latest_release ? 'you appear to be using a non-production version of Chrome; ' : ''
          msg = "#{msg}please set `Webdrivers::Chromedriver.required_version = <desired driver version>` to an known "\
'chromedriver version: https://chromedriver.storage.googleapis.com/index.html'
          raise VersionError, msg
        end
      end

      def platform
        if Selenium::WebDriver::Platform.linux?
          'linux64'
        elsif Selenium::WebDriver::Platform.mac?
          'mac64'
        elsif Selenium::WebDriver::Platform.windows?
          'win32'
        else
          raise NotImplementedError, 'Your OS is not supported by webdrivers gem.'
        end
      end

      def file_name
        Selenium::WebDriver::Platform.windows? ? 'chromedriver.exe' : 'chromedriver'
      end

      def base_url
        'https://chromedriver.storage.googleapis.com'
      end

      def download_url
        return @download_url if @download_url

        version = if required_version.version.empty?
                    latest_version
                  else
                    normalize_version(required_version)
                  end

        url = "#{base_url}/#{version}/chromedriver_#{platform}.zip"
        Webdrivers.logger.debug "chromedriver URL: #{url}"
        @download_url = url
      end

      # Returns release version from the currently installed Chrome version
      #
      # @example
      #   73.0.3683.75 -> 73.0.3683
      def release_version
        chrome = normalize_version(chrome_version)
        normalize_version(chrome.segments[0..2].join('.'))
      end

      def chrome_on_win32
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return system_call("powershell (Get-ItemProperty '#{browser_binary}').VersionInfo.ProductVersion").strip
        end

        # Workaround for Google Chrome when using Jruby on Windows.
        # @see https://github.com/titusfortner/webdrivers/issues/41
        if RUBY_PLATFORM == 'java'
          ver = 'powershell (Get-Item -Path ((Get-ItemProperty "HKLM:\\Software\\Microsoft' \
          "\\Windows\\CurrentVersion\\App` Paths\\chrome.exe\").\\'(default)\\'))" \
          '.VersionInfo.ProductVersion'
          return system_call(ver).strip
        end

        # Default to Google Chrome
        reg = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'
        executable = system_call("powershell (Get-ItemProperty '#{reg}' -Name '(default)').'(default)'").strip
        Webdrivers.logger.debug "Browser executable: '#{executable}'"
        ps = "(Get-Item (Get-ItemProperty '#{reg}').'(default)').VersionInfo.ProductVersion"
        system_call("powershell #{ps}").strip
      end

      def chrome_on_linux64
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return system_call("#{Shellwords.escape browser_binary} --product-version").strip
        end

        # Default to Google Chrome
        executable = system_call('which google-chrome').strip
        Webdrivers.logger.debug "Browser executable: '#{executable}'"
        system_call("#{executable} --product-version").strip
      end

      def chrome_on_mac64
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return system_call("#{Shellwords.escape browser_binary} --version").strip
        end

        # Default to Google Chrome
        executable = Shellwords.escape '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
        Webdrivers.logger.debug "Browser executable: #{executable}"
        system_call("#{executable} --version").strip
      end

      #
      # Returns user defined browser executable path from Selenium::WebDrivers::Chrome#path.
      #
      def browser_binary
        # For Chromium, Brave, or whatever else
        Selenium::WebDriver::Chrome.path
      end

      def sufficient_binary?
        super && current_version && (current_version < normalize_version('70.0.3538') ||
            current_version.segments.first == release_version.segments.first)
      end
    end
  end
end

if ::Selenium::WebDriver::Service.respond_to? :driver_path=
  ::Selenium::WebDriver::Chrome::Service.driver_path = proc { ::Webdrivers::Chromedriver.update }
else
  # v3.141.0 and lower
  module Selenium
    module WebDriver
      module Chrome
        def self.driver_path
          @driver_path ||= Webdrivers::Chromedriver.update
        end
      end
    end
  end
end
