module Webdrivers
  class MSWebdriver < Common
    class << self

      def current
        Webdrivers.logger.debug "Checking current version"
        version = %x(ver)
        Webdrivers.logger.debug "Current version of Windows Build is #{version}"
        version[/\d+\.\d+\.\d+/][/[^\.]\d+$/]
      end

      def latest
        # unknown; have to always download
      end

      private

      def normalize(string)
        string.match(/(\d+)\.(\d+\.\d+)/).to_a.map {|v| v.tr('.', '')}[1..-1].join('.').to_f
      end

      def file_name
        "MicrosoftWebDriver.exe"
      end

      def download_url(_version = nil)
        raise StandardError, "Can not reach site" unless site_available?

        case current.to_i
        when 10240
          Webdrivers.logger.debug "Attempting to Download Build for 10240"
          "https://download.microsoft.com/download/8/D/0/8D0D08CF-790D-4586-B726-C6469A9ED49C/MicrosoftWebDriver.msi"
        when 10586
          Webdrivers.logger.debug "Attempting to Download Build for 10586"
          "https://download.microsoft.com/download/C/0/7/C07EBF21-5305-4EC8-83B1-A6FCC8F93F45/MicrosoftWebDriver.msi"
        when 14393
          Webdrivers.logger.debug "Attempting to Download Build for 14393"
          "https://download.microsoft.com/download/3/2/D/32D3E464-F2EF-490F-841B-05D53C848D15/MicrosoftWebDriver.exe"
        when 15063
          Webdrivers.logger.debug "Attempting to Download Build for 15063"
          "https://download.microsoft.com/download/3/4/2/342316D7-EBE0-4F10-ABA2-AE8E0CDF36DD/MicrosoftWebDriver.exe"
        else
          Webdrivers.logger.debug "Attempting to Download Latest Insider's Version"
          "https://download.microsoft.com/download/1/4/1/14156DA0-D40F-460A-B14D-1B264CA081A5/MicrosoftWebDriver.exe"
        end
      end

      def base_url
        'https://www.microsoft.com/en-us/download'
      end

    end
  end
end