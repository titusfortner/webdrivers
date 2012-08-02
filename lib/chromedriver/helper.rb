require "chromedriver/helper/version"
require "chromedriver/helper/google_code_parser"
require 'fileutils'
require 'open-uri'

module Chromedriver
  class Helper
    DOWNLOAD_URL = "http://code.google.com/p/chromedriver/downloads/list"

    def run *args
      download
      exec binary_path, *args
    end

    def download hit_network=false
      return if File.exists?(binary_path) && ! hit_network
      url = download_url
      filename = File.basename url
      Dir.chdir platform_install_dir do
        unless File.exists? filename
          system("wget -c -O #{filename} #{url}") || system("curl -C - -o #{filename} #{url}")
          raise "Could not download #{url}" unless File.exists? filename
          system "unzip -o #{filename}"
        end
      end
      raise "Could not unzip #{filename} to get #{binary_path}" unless File.exists? binary_path
    end

    def update
      download true
    end

    def download_url
      downloads = GoogleCodeParser.new(open(DOWNLOAD_URL)).downloads
      url = downloads.grep(/chromedriver_#{platform}_.*\.zip/).first
      url = "http:#{url}" if url !~ /^http/
      url
    end

    def binary_path
      File.join platform_install_dir, "chromedriver"
    end

    def platform_install_dir
      dir = File.join install_dir, platform
      FileUtils.mkdir_p dir
      dir
    end

    def install_dir
      dir = File.expand_path File.join(ENV['HOME'], ".chromedriver-helper")
      FileUtils.mkdir_p dir
      dir
    end

    def platform
      case RUBY_PLATFORM
      when /64.*linux|linux.*64/ then "linux64"
      when /linux/ then "linux32"
      when /darwin/ then "mac"
      else "win"
      end
    end
  end
end
