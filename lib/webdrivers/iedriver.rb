require 'nokogiri'

module Webdrivers
  class IEDriver < Common

    class << self
      def file_name
        "IEDriverServer.exe"
      end

      def current_version
        return nil unless File.exists?(binary_path)
        %x(#{binary_path} --version).strip.match(/IEDriverServer.exe (\d\.\d+\.\d*\.\d*)/)[1]
      end

      def newest_version
        downloads.keys.sort.last
      end

      def downloads
        doc = Nokogiri::XML.parse(OpenURI.open_uri(base_url))
        items = doc.css("Key").collect(&:text)
        items.select! { |item| item.include?('IEDriverServer_Win32') }
        items.each_with_object({}) do |item, hash|
          hash[item[/^[^\/]+/]] = "#{base_url}#{item}"
        end
      end

      def base_url
        'http://selenium-release.storage.googleapis.com/'
      end
    end

  end
end