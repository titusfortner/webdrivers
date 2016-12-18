require 'nokogiri'

module Webdrivers
  class Edgedriver < Common

    class << self
      def file_name
        "MicrosoftWebDriver.exe"
      end

      def current_version
        # No version information available
      end

      def newest_version
        version = %x(ver)
        version[/\d+\.\d+\.\d+/][/[^\.]\d+$/]
      end

      def download_url(version = nil)
        if newest_version.to_i >= 14986
          'https://download.microsoft.com/download/1/4/1/14156DA0-D40F-460A-B14D-1B264CA081A5/MicrosoftWebDriver.exe'
        else
          'https://download.microsoft.com/download/3/2/D/32D3E464-F2EF-490F-841B-05D53C848D15/MicrosoftWebDriver.exe'
        end
      end

      def base_url
        'http://google.com'
      end
    end

  end
end