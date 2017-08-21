require 'nokogiri'
require 'open-uri'

module Webdrivers
  class Geckodriver < Common
    class << self

      def current
        Webdrivers.logger.debug "Checking current version"
        return nil unless downloaded?
        string = %x(#{binary} --version)
        Webdrivers.logger.debug "Current version of #{binary} is #{string}"
        normalize string.match(/geckodriver (\d+\.\d+\.\d+)/)[1]
      end

      private

      def normalize(string)
        string.match(/(\d+)\.(\d+\.\d+)/).to_a.map {|v| v.tr('.', '')}[1..-1].join('.').to_f
      end

      def downloads
        raise StandardError, "Can not reach site" unless site_available?
        Webdrivers.logger.debug "Versions previously located on downloads site: #{@downloads.keys}" if @downloads

        @downloads ||= begin
          doc = Nokogiri::XML.parse(OpenURI.open_uri(base_url))
          items = doc.css(".release-downloads a").collect {|item| item["href"]}
          items.reject! {|item| item.include?('archive')}
          items.select! {|item| item.include?(platform)}
          ds = items.each_with_object({}) do |item, hash|
            key = normalize item[/v(\d+\.\d+\.\d+)/, 1]
            hash[key] = "https://github.com#{item}"
          end
          Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
          ds
        end
      end

      def file_name
        platform == "win" ? "geckodriver.exe" : "geckodriver"
      end

      def base_url
        'https://github.com/mozilla/geckodriver/releases'
      end

    end
  end
end