require 'nokogiri'

module Webdrivers
  class PhantomJS < Common

    class << self
      def file_name
        platform == "win" ? "phantomjs.exe" : "phantomjs"
      end

      def current_version
        return nil unless File.exists?(binary_path)
        %x(#{binary_path} --version).strip.match(/(\d\.\d+\.\d+)/)[1]
      end

      def newest_version
        downloads.keys.sort.last
      end

      def downloads
        doc = Nokogiri::XML.parse(OpenURI.open_uri(base_url))
        items = doc.css(".execute").collect { |item| item["href"] }
        format_platform = platform.dup.gsub('32', '-i686').gsub('64', '-x86_64')
        items.select! { |item| item.include?(format_platform) }
        items.each_with_object({}) do |item, hash|
          hash[item[/-(\d+\.\d+\.\d+)-/, 1]] = "https://bitbucket.org#{item}"
        end
      end

      def base_url
        'https://bitbucket.org/ariya/phantomjs/downloads'
      end

      def extract_file(filename)
        FileUtils.mv("#{platform_install_dir}/#{filename}/bin/#{file_name}", file_name)
      end
    end

  end
end