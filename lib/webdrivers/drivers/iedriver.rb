# frozen_string_literal: true

require 'nokogiri'

module Webdrivers
  class IEdriver < Common
    class << self
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless downloaded?

        version = binary_version
        return nil if version.nil?

        normalize_version version.match(/IEDriverServer.exe (\d\.\d+\.\d+)/)[1]
      end

      def latest_version
        @latest_version ||= if System.valid_cache?(file_name)
                              normalize_version(System.cached_version(file_name))
                            else
                              Webdrivers.logger.warn 'Driver caching is turned off in this version, but will '\
                              'be enabled by default in 4.x. Set the value now with `Webdrivers#cache_time=` in seconds'
                              version = downloads.keys.max
                              System.cache_version(file_name, version)
                              version
                            end
      end

      private

      def file_name
        'IEDriverServer.exe'
      end

      def base_url
        'https://selenium-release.storage.googleapis.com/'
      end

      def downloads
        doc = Nokogiri::XML.parse(Network.get(base_url))
        items = doc.css('Key').collect(&:text)
        items.select! { |item| item.include?('IEDriverServer_Win32') }
        ds = items.each_with_object({}) do |item, hash|
          key = normalize_version item[/([^_]+)\.zip/, 1]
          hash[key] = "#{base_url}#{item}"
        end
        Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
        ds
      end
    end
  end
end
