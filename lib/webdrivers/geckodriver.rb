require 'nokogiri'

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
        string.scan(/\d+/).map(&:to_i)
      end

      def downloads
        raise StandardError, "Can not reach site" unless site_available?
        Webdrivers.logger.debug "Versions previously located on downloads site: #{@downloads.keys}" if @downloads

        @downloads ||= begin
          doc = JSON.parse(get(base_url))

          tags_and_urls = doc.flat_map do |release|
            release['assets'].map {|asset| [release['tag_name'], asset['browser_download_url']]}
          end

          tags_and_urls = tags_and_urls
            .select {|vers, url| url.include?(platform)}
            .map {|vers, url| [normalize(vers), url]}

          ds = Hash[tags_and_urls]
          Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
          ds
        end
      end

      def file_name
        platform == "win" ? "geckodriver.exe" : "geckodriver"
      end

      def base_url
        'https://api.github.com/repos/mozilla/geckodriver/releases'
      end

    end
  end
end
