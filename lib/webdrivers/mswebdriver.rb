# frozen_string_literal: true

require 'nokogiri'

module Webdrivers
  class MSWebdriver < Common
    class << self
      attr_accessor :ignore, :file_name

      def current_version
        raise NotImplementedError, 'Unable to programatically determine the version of most MicrosoftWebDriver.exe'
      end

      def windows_version
        return @windows_version if @windows_version

        # current_version() from other webdrivers returns the version from the webdriver EXE.
        # Unfortunately, MicrosoftWebDriver.exe does not have an option to get the version.
        # To work around it we query the currently installed version of Microsoft Edge instead
        # and compare it to the list of available downloads.
        version = system_call('powershell (Get-AppxPackage -Name Microsoft.MicrosoftEdge).Version')
        raise VersionError, 'Failed to check Microsoft Edge version' if version.empty? # Package name changed?

        Webdrivers.logger.debug "Current version of Microsoft Edge is #{version}"

        @windows_version = Gem::Version.new(version)
      end

      def latest_version
        return @latest_version if @latest_version

        if windows_version.segments.first == 45
          raise VersionError, 'Webdrivers is unable to provide this driver; Run this command: '\
          '`DISM.exe /Online /Add-Capability /CapabilityName:Microsoft.WebDriver~~~~0.0.1.0` '\
          'as discussed here: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/#downloads; '\
          'Also please set `Webdrivers::MSWebdriver.ignore = true`'
        end

        version = if windows_version < Gem::Version.new(44)
                    @file_name = 'MicrosoftWebDriver.exe'
                    windows_version.segments[1]
                  else
                    @file_name = 'msedgedriver.exe'
                    '75'
                  end

        Webdrivers.logger.debug "Desired build of Microsoft WebDriver is #{version}"

        @latest_version = Gem::Version.new(version)
      end

      def remove
        @download_url = nil
        @latest_version = nil
        Webdrivers.logger.debug 'Deleting MicrosoftWebDriver.exe'
        FileUtils.rm_f(File.join(install_dir, 'MicrosoftWebDriver.exe'))
        Webdrivers.logger.debug 'Deleting msedgedriver.exe'
        FileUtils.rm_f(File.join(install_dir, 'msedgedriver.exe'))
      end

      def binary
        latest_version
        File.join install_dir, @file_name
      end

      private

      def base_url
        'https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/'
      end

      def download_url
        @download_url ||= if desired_version.to_s == '75'
                            if Selenium::WebDriver::Platform.bitsize == 64
                              'https://az813057.vo.msecnd.net/webdriver/msedgedriver_x64/msedgedriver.exe'
                            else
                              'https://az813057.vo.msecnd.net/webdriver/msedgedriver_x86/msedgedriver.exe'
                            end
                          else
                            downloads[desired_version]
                          end
      end

      def downloads
        array = Nokogiri::HTML(get(base_url)).xpath("//li[@class='driver-download']/a")
        array.each_with_object({}) do |link, hash|
          next if link.text == 'Insiders'

          key = normalize_version link.text.scan(/\d+/).first.to_i
          hash[key] = link['href']
        end
      end

      # Assume we have the latest if we are offline and file exists
      def correct_binary?
        get(base_url)
        false
      rescue ConnectionError
        File.exist?(binary)
      end
    end
  end
end
