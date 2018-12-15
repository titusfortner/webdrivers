require 'nokogiri'

module Webdrivers
  class Chromedriver < Common
    class << self

      def current_version
        Webdrivers.logger.debug "Checking current version"
        return nil unless downloaded?
        string = %x(#{binary} --version)
        Webdrivers.logger.debug "Current version of #{binary} is #{string}"
        normalize string.match(/ChromeDriver (\d\.\d+)/)[1]
      end

      def latest
        Gem::Version.new(get(URI.join(base_url, "LATEST_RELEASE")))
      end

      private

      def file_name
        platform == "win" ? "chromedriver.exe" : "chromedriver"
      end

      def base_url
        'http://chromedriver.storage.googleapis.com'
      end

      def downloads
        raise StandardError, "Can not download from website" unless site_available?
        Webdrivers.logger.debug "Versions previously located on downloads site: #{@downloads.keys}" if @downloads

        @downloads ||= begin
          doc = Nokogiri::XML.parse(get(base_url))
          items = doc.css("Contents Key").collect(&:text)
          items.select! {|item| item.include?(platform)}
          ds = items.each_with_object({}) do |item, hash|
            key = normalize item[/^[^\/]+/]
            hash[key] = "#{base_url}/#{item}"
          end
          Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
          ds
        end
      end

    end
  end
end