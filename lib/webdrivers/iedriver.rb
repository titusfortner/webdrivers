require 'nokogiri'
require 'rubygems/version'

module Webdrivers
  class IEdriver < Common
    class << self

      def current_version
        Webdrivers.logger.debug "Checking current version"
        return nil unless downloaded?
        string = %x(#{binary} --version)
        Webdrivers.logger.debug "Current version of #{binary} is #{string}"
        normalize string.match(/IEDriverServer.exe (\d\.\d+\.\d*\.\d*)/)[1]
      end

      private

      def file_name
        "IEDriverServer.exe"
      end

      def base_url
        'http://selenium-release.storage.googleapis.com/'
      end

      def downloads
        raise StandardError, "Can not reach site" unless site_available?
        Webdrivers.logger.debug "Versions previously located on downloads site: #{@downloads.keys}" if @downloads

        @downloads ||= begin
          doc = Nokogiri::XML.parse(get(base_url))
          items = doc.css("Key").collect(&:text)
          items.select! { |item| item.include?('IEDriverServer_Win32') }
          ds = items.each_with_object({}) do |item, hash|
            key = normalize item[/([^_]+)\.zip/, 1]
            hash[key] = "#{base_url}#{item}"
          end
          Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
          ds
        end
      end

    end
  end
end