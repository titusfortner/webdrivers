# frozen_string_literal: true

require 'shellwords'
require 'webdrivers/common'
require 'webdrivers/edgedriver'
require 'webdrivers/edge_finder'

module Webdrivers
  class Edgedriver < Chromedriver
    class << self
      #
      # Returns latest available chromedriver version.
      #
      # @return [Gem::Version]
      def latest_version
        @latest_version ||= begin
          latest_applicable = with_cache(file_name) { latest_point_release(release_version) }

          Webdrivers.logger.debug "Latest version available: #{latest_applicable}"
          normalize_version(latest_applicable)
        end
      end

      #
      # Returns currently installed Chrome/Chromium version.
      #
      # @return [Gem::Version]
      def edge_version
        normalize_version EdgeFinder.version
      end

      #
      # Returns url with domain for calls to get this driver.
      #
      # @return [String]
      def base_url
        'https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/'
      end

      def remove
        super
        @downloads = nil
      end

      private

      def latest_point_release(version)
        begin
          lpr = downloads.keys.select { |ver| ver.segments[0..2] == version.segments[0..2] }.max
          return normalize_version(lpr) if lpr
        rescue NetworkError # rubocop:disable Lint/HandleExceptions
        end
        msg = failed_to_find_message(version)
        Webdrivers.logger.debug msg
        raise VersionError, msg
      end

      def failed_to_find_message(version)
        msg = "Unable to find latest point release version for #{version}."
        msg = begin
          latest_release = normalize_version(downloads.keys.max)
          if version > latest_release
            "#{msg} You appear to be using a non-production version of Edge."
          else
            msg
          end
              rescue NetworkError
                "#{msg} A network issue is preventing determination of latest msedgedriver release."
        end

        "#{msg} Please set `Webdrivers::Edgedriver.required_version = <desired driver version>` "\
        "to a known edgedriver version: #{base_url}"
      end

      def file_name
        System.platform == 'win' ? 'msedgedriver.exe' : 'msedgedriver'
      end

      def download_url
        return @download_url if @download_url

        version = if required_version == EMPTY_VERSION
                    latest_version
                  else
                    normalize_version(required_version)
                  end

        url = downloads[version]
        Webdrivers.logger.debug "edgedriver URL: #{url}"
        @download_url = url
      end

      # Returns release version from the currently installed Chrome version
      #
      # @example
      #   73.0.3683.75 -> 73.0.3683
      def release_version
        edge = normalize_version(edge_version)
        normalize_version(edge.segments[0..2].join('.'))
      end

      def sufficient_binary?
        super && current_version && (current_version.segments.first == release_version.segments.first)
      end

      def downloads
        @downloads ||= begin
          ds = parse_downloads(Network.get(base_url))
          Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
          ds
                       rescue Webdrivers::NetworkError
                         {}
        end
      end

      def parse_downloads(html)
        driver_download_url = 'https://msedgewebdriverstorage.blob.core.windows.net/edgewebdriver/'
        doc = Nokogiri::XML.parse(html)
        doc.css(".driver-download__meta a[href^='#{driver_download_url}']")
           .map { |a| a['href'] }
           .select { |item| item.include?(System.platform == 'win' ? 'win32' : "#{System.platform}64") }
           .each_with_object({}) do |url, hash|
             hash[normalize_version url[%r{/([0-9\.]+)/edgedriver_(.*)\.zip$}, 1]] = url
           end
      end
    end
  end
end

if defined? Selenium::WebDriver::EdgeChrome
  if ::Selenium::WebDriver::Service.respond_to? :driver_path=
    ::Selenium::WebDriver::EdgeChrome::Service.driver_path = proc { ::Webdrivers::Edgedriver.update }
  else
    # v3.141.0 and lower
    module Selenium
      module WebDriver
        module EdgeChrome
          def self.driver_path
            @driver_path ||= Webdrivers::Edgedriver.update
          end
        end
      end
    end
  end
end
