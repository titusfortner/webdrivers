# frozen_string_literal: true

require 'nokogiri'
require 'shellwords'
require 'webdrivers/common'

module Webdrivers
  class Chromedriver < Common
    class << self
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless exists?

        ver = `#{binary} --version`
        Webdrivers.logger.debug "Current #{binary} version: #{ver}"

        # Matches 2.46, 2.46.628411 and 73.0.3683.75
        normalize_version ver[/\d+\.\d+(\.\d+)?(\.\d+)?/]
      end

      def latest_version
        @latest_version ||= begin
          raise StandardError, 'Can not reach site' unless site_available?

          # Versions before 70 do not have a LATEST_RELEASE file
          return normalize_version('2.46') if release_version < normalize_version('70.0.3538')

          latest_applicable = latest_point_release(release_version)

          Webdrivers.logger.debug "Latest version available: #{latest_applicable}"
          normalize_version(latest_applicable)
        end
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
          msg = "#{msg}please set `Webdrivers::Chromedriver.version = <desired driver version>` to an known "\
'chromedriver version: https://chromedriver.storage.googleapis.com/index.html'
          raise StandardError, msg
        end
      end

      def platform
        if Selenium::WebDriver::Platform.linux?
          'linux64'
        elsif Selenium::WebDriver::Platform.mac?
          'mac64'
        else
          'win32'
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

        url = "#{base_url}/#{desired_version}/chromedriver_#{platform}.zip"
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

      # Returns currently installed Chrome version
      def chrome_version
        ver = case platform
              when 'win32'
                chrome_on_windows
              when 'linux64'
                chrome_on_linux
              when 'mac64'
                chrome_on_mac
              else
                raise NotImplementedError, 'Your OS is not supported by webdrivers gem.'
              end.chomp

        raise StandardError, 'Failed to find Chrome binary or its version.' if ver.nil? || ver.empty?

        Webdrivers.logger.debug "Browser version: #{ver}"
        normalize_version ver[/\d+\.\d+\.\d+\.\d+/] # Google Chrome 73.0.3683.75 -> 73.0.3683.75
      end

      def chrome_on_windows
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return `powershell (Get-ItemProperty '#{browser_binary}').VersionInfo.ProductVersion`.strip
        end

        # Workaround for Google Chrome when using Jruby on Windows.
        # @see https://github.com/titusfortner/webdrivers/issues/41
        if RUBY_PLATFORM == 'java'
          ver = 'powershell (Get-Item -Path ((Get-ItemProperty "HKLM:\\Software\\Microsoft' \
          "\\Windows\\CurrentVersion\\App` Paths\\chrome.exe\").\\'(default)\\'))" \
          '.VersionInfo.ProductVersion'
          return `#{ver}`.strip
        end

        # Default to Google Chrome
        reg        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'
        executable = `powershell (Get-ItemProperty '#{reg}' -Name '(default)').'(default)'`.strip
        Webdrivers.logger.debug "Browser executable: '#{executable}'"
        ps = "(Get-Item (Get-ItemProperty '#{reg}').'(default)').VersionInfo.ProductVersion"
        `powershell #{ps}`.strip
      end

      def chrome_on_linux
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return `#{Shellwords.escape browser_binary} --product-version`.strip
        end

        # Default to Google Chrome
        executable = `which google-chrome`.strip
        Webdrivers.logger.debug "Browser executable: '#{executable}'"
        `#{executable} --product-version`.strip
      end

      def chrome_on_mac
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return `#{Shellwords.escape browser_binary} --version`.strip
        end

        # Default to Google Chrome
        executable = Shellwords.escape '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
        Webdrivers.logger.debug "Browser executable: #{executable}"
        `#{executable} --version`.strip
      end

      #
      # Returns user defined browser executable path from Selenium::WebDrivers::Chrome#path.
      #
      def browser_binary
        # For Chromium, Brave, or whatever else
        Selenium::WebDriver::Chrome.path
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
