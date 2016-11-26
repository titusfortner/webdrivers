require 'nokogiri'

module Webdrivers
  class Geckodriver < Common

    class << self
      def file_name
        platform == "win" ? "geckodriver.exe" : "geckodriver"
      end

      def current_version
        return nil unless File.exists?(binary_path)
        %x(#{binary_path} --version).match(/geckodriver (\d\.\d+\.\d+)/)[1]
      end

      def newest_version
        padded = downloads.keys.each_with_object({}) do |version, hash|
          matched = version.match(/^(\d+)\.(\d+)\.(\d+)$/)
          minor = sprintf '%02d', matched[2]
          hash["#{matched[1]}.#{minor}.#{matched[3]}"] = version
        end
        padded.keys.sort.last
      end

      def downloads
        doc = Nokogiri::XML.parse(OpenURI.open_uri(base_url))
        items = doc.css(".release-downloads a").collect {|item| item["href"]}
        items.reject! {|item| item.include?('archive')}
        items.select! {|item| item.include?(platform)}
        items.each_with_object({}) do |item, hash|
          hash[item[/v(\d+\.\d+\.\d+)/, 1]] = "https://github.com#{item}"
        end
      end

      def base_url
        'https://github.com/mozilla/geckodriver/releases'
      end

    end

  end
end