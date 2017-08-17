require 'nokogiri'
require 'open-uri'

module Webdrivers
  class IEdriver < Common
    class << self

      def current
        return nil unless downloaded?
        puts binary
        string = %x(#{binary} --version)
        puts string
        normalize string.match(/IEDriverServer.exe (\d\.\d+\.\d*\.\d*)/)[1]
      end

      private

      def normalize(string)
        string.to_f
      end

      def file_name
        "IEDriverServer.exe"
      end

      def base_url
        'http://selenium-release.storage.googleapis.com/'
      end

      def downloads
        raise StandardError, "Can not reach site" unless site_available?

        @downloads ||= begin
          doc = Nokogiri::XML.parse(OpenURI.open_uri(base_url))
          items = doc.css("Key").collect(&:text)
          items.select! { |item| item.include?('IEDriverServer_Win32') }
          items.each_with_object({}) do |item, hash|
            key = normalize item[/^[^\/]+/]
            hash[key] = "#{base_url}#{item}"
          end
        end
      end

    end
  end
end