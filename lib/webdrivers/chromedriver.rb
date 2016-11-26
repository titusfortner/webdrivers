require 'nokogiri'

module Webdrivers
  class Chromedriver < Common

    class << self
      def file_name
        platform == "win" ? "chromedriver.exe" : "chromedriver"
      end

      def current_version
        return nil unless File.exists?(binary_path)
        %x(#{binary_path} --version).match(/ChromeDriver (\d\.\d+)/)[1]
      end

      def newest_version
        padded = downloads.keys.each_with_object({}) do |version, hash|
          matched = version.match(/^(\d+)\.(\d+)$/)
          minor = sprintf '%02d', matched[2]
          hash["#{matched[1]}.#{minor}"] = version
        end
        padded.keys.sort.last
      end

      def downloads
        doc = Nokogiri::XML.parse(OpenURI.open_uri(base_url))
        items = doc.css("Contents Key").collect(&:text)
        items.select! { |item| item.include?(platform) }
        items.each_with_object({}) do |item, hash|
          hash[item[/^[^\/]+/]] = "#{base_url}/#{item}"
        end
      end

      def base_url
        'http://chromedriver.storage.googleapis.com'
      end

    end

  end
end