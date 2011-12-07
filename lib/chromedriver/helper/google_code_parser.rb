require 'nokogiri'

module Chromedriver
  class Helper
    class GoogleCodeParser
      attr_reader :html

      def initialize html
        @html = html
      end

      def downloads
        doc = Nokogiri::HTML html
        doc.css("td.vt a[@title=Download]").collect {|_| _["href"]}
      end
    end
  end
end
