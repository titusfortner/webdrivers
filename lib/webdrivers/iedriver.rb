require 'nokogiri'

module Webdrivers
  class IEdriver < Common
    class << self

      def current
        Webdrivers.logger.debug "Checking current version"
        return nil unless downloaded?
        string = %x(#{binary} --version)
        Webdrivers.logger.debug "Current version of #{binary} is #{string}"
        normalize string.match(/IEDriverServer.exe (\d\.\d+\.\d*\.\d*)/)[1]
      end

      def latest
        downloads.keys.sort {|a,b| compare_versions(a, b)}.last
      end


      private

      def compare_versions(a, b)
        a = float_to_digits_array(a) if a.is_a?(Float)
        b = float_to_digits_array(b) if b.is_a?(Float)
        if a.size == 1
          a[0] <=> b[0]
        elsif a[0] == b[0]
          compare_versions *[a,b].map {|v| v.drop(1)}
        else
          a[0] <=> b[0]
        end
      end

      def float_to_digits_array(float_value)
        float_value.to_s.split('.').map(&:to_i)
      end

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
        Webdrivers.logger.debug "Versions previously located on downloads site: #{@downloads.keys}" if @downloads

        @downloads ||= begin
          doc = Nokogiri::XML.parse(get(base_url))
          items = doc.css("Key").collect(&:text)
          items.select! { |item| item.include?('IEDriverServer_Win32') }
          ds = items.each_with_object({}) do |item, hash|
            key = normalize item[/^[^\/]+/]
            hash[key] = "#{base_url}#{item}"
          end
          Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
          ds
        end
      end

    end
  end
end