require 'nokogiri'
require 'open-uri'

module Webdrivers
  class MSWebdriver < Common
    class << self

      def current
        version = %x(ver)
        version[/\d+\.\d+\.\d+/][/[^\.]\d+$/]
      end

      def latest
        # unknown; have to always download
      end

      private

      def normalize(string)
        string.match(/(\d+)\.(\d+\.\d+)/).to_a.map {|v| v.tr('.', '') }[1..-1].join('.').to_f
      end

      def file_name
        "MicrosoftWebDriver.exe"
      end

      def download_url(_version = nil)
        raise StandardError, "Can not reach site" unless site_available?

        if current.to_i >= 16257
          'https://download.microsoft.com/download/1/4/1/14156DA0-D40F-460A-B14D-1B264CA081A5/MicrosoftWebDriver.exe'
        else
          'https://download.microsoft.com/download/3/2/D/32D3E464-F2EF-490F-841B-05D53C848D15/MicrosoftWebDriver.exe'
        end
      end

      def base_url
        'https://www.microsoft.com/en-us/download'
      end

    end
  end
end