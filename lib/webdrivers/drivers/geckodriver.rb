# frozen_string_literal: true

require 'nokogiri'

module Webdrivers
  class Geckodriver < Common
    class << self
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless downloaded?

        version = binary_version
        return nil if version.nil?

        normalize_version version.match(/geckodriver (\d+\.\d+\.\d+)/)[1]
      end

      private

      def file_name
        platform == 'win' ? 'geckodriver.exe' : 'geckodriver'
      end

      def base_url
        'https://github.com/mozilla/geckodriver/releases'
      end

      def downloads # rubocop:disable  Metrics/AbcSize
        doc = Nokogiri::HTML.parse(Network.get(base_url))
        items = doc.css('.py-1 a').collect { |item| item['href'] }
        items.reject! { |item| item.include?('archive') }
        items.select! { |item| item.include?(platform) }
        ds = items.each_with_object({}) do |item, hash|
          key = normalize_version item[/v(\d+\.\d+\.\d+)/, 1]
          hash[key] = "https://github.com#{item}"
        end
        Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
        ds
      end
    end
  end
end
