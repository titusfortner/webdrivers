require 'nokogiri'
require 'open-uri'
require 'zip'

module Webdrivers
  class Chromedriver < Common
    class << self

      def current
        return nil unless downloaded?
        puts binary
        string = %x(#{binary} --version)
        puts string
        normalize string.match(/ChromeDriver (\d\.\d+)/)[1]
      end

      private

      def normalize(string)
        string.size == 3 ? string.gsub('.', '.0').to_f : string.to_f
      end

      def file_name
        'chromedriver'
      end

      def base_url
        'http://chromedriver.storage.googleapis.com'
      end

      def downloads
        raise StandardError, "Can not reach site" unless site_available?

        @downloads ||= begin
          doc = Nokogiri::XML.parse(OpenURI.open_uri(base_url))
          items = doc.css("Contents Key").collect(&:text)
          items.select! {|item| item.include?(platform)}
          items.each_with_object({}) do |item, hash|
            key = normalize item[/^[^\/]+/]
            hash[key] = "#{base_url}/#{item}"
          end
        end
      end

    end
  end
end