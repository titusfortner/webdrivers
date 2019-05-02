# frozen_string_literal: true

require 'nokogiri'

module Webdrivers
  class MSWebdriver < Common
    class << self
      def windows_version
        Webdrivers.logger.debug 'Checking current version'

        # current_version() from other webdrivers returns the version from the webdriver EXE.
        # Unfortunately, MicrosoftWebDriver.exe does not have an option to get the version.
        # To work around it we query the currently installed version of Microsoft Edge instead
        # and compare it to the list of available downloads.
        version = system_call('powershell (Get-AppxPackage -Name Microsoft.MicrosoftEdge).Version')
        raise 'Failed to check Microsoft Edge version.' if version.empty? # Package name changed?

        Webdrivers.logger.debug "Current version of Microsoft Edge is #{version.dup.chomp!}"

        build = version.split('.')[1] # "41.16299.248.0" => "16299"
        Webdrivers.logger.debug "Expecting MicrosoftWebDriver.exe version #{build}"
        Gem::Version.new(build)
      end

      # Webdriver binaries for Microsoft Edge are not backwards compatible.
      # For this reason, instead of downloading the latest binary we download the correct one for the
      # currently installed browser version.
      alias version windows_version

      def version=(*)
        raise 'Version can not be set for MSWebdriver because it is dependent on the version of Edge'
      end

      private

      def file_name
        'MicrosoftWebDriver.exe'
      end

      def base_url
        'https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/'
      end

      def download_url
        @download_url ||= downloads[windows_version]
      end

      def downloads
        array = Nokogiri::HTML(get(base_url)).xpath("//li[@class='driver-download']/a")
        array.each_with_object({}) do |link, hash|
          next if link.text == 'Insiders'

          key = normalize_version link.text.scan(/\d+/).first.to_i
          hash[key] = link['href']
        end
      end
    end
  end
end
