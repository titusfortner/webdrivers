require 'nokogiri'
require 'open-uri'
require 'zip'


module Webdrivers
  class Chromedriver
    class << self

      def update
        unless site_available?
          return current.nil? ? nil : binary
        end
        return binary if current == latest
        remove && download
      end

      def current
        return nil unless downloaded?
        puts binary
        string = %x(#{binary} --version)
        puts string
        normalize string.match(/ChromeDriver (\d\.\d+)/)[1]
      end

      def latest
        downloads.keys.sort.last
      end

      def remove
        FileUtils.rm_f binary
      end

      def download(version = nil)
        url = downloads[version || latest]
        filename = File.basename url

        Dir.chdir install_dir do
          FileUtils.rm_f filename
          File.open(filename, "wb") do |saved_file|
            URI.parse(url).open("rb") do |read_file|
              saved_file.write(read_file.read)
            end
          end
          raise "Could not download #{url}" unless File.exists? filename
          dcf = decompress_file(filename)
          extract_file(dcf) if respond_to? :extract_file
        end
        raise "Could not unzip #{filename} to get #{binary}" unless File.exists?(binary)
        FileUtils.chmod "ugo+rx", binary
        binary
      end

      private

      def normalize(string)
        string.size == 3 ? string.gsub('.', '.0').to_f : string.to_f
      end

      def file_name
        'chromedriver'
      end

      def downloaded?
        File.exist? binary
      end

      def binary
        File.join install_dir, file_name
      end

      def base_url
        'http://chromedriver.storage.googleapis.com'
      end

      def site_available?
        true if open(base_url)
      rescue
        false
      end

      def platform
        cfg = RbConfig::CONFIG
        case cfg['host_os']
        when /linux/
          cfg['host_cpu'] =~ /x86_64|amd64/ ? "linux64" : "linux32"
        when /darwin/
          "mac"
        else
          "win"
        end
      end

      def decompress_file(filename)
        case filename
        when /tar\.gz$/
          untargz_file(filename)
        when /tar\.bz2$/
          system "tar xjf #{filename}"
          filename.gsub('.tar.bz2', '')
        when /\.zip$/
          unzip_file(filename)
        end
      end

      def untargz_file(filename)
        tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(filename))
        tar_extract.rewind

        ucf = File.open(file_name, "w+")
        tar_extract.each {|entry| ucf << entry.read}
        ucf.close
        File.basename ucf
      end

      def unzip_file(filename)
        Zip::File.open("#{Dir.pwd}/#{filename}") do |zip_file|
          zip_file.each do |f|
            @top_path ||= f.name
            f_path = File.join(Dir.pwd, f.name)
            FileUtils.rm_rf(f_path) if File.exist?(f_path)
            FileUtils.mkdir_p(File.dirname(f_path)) unless File.exist?(File.dirname(f_path))
            zip_file.extract(f, f_path)
          end
        end
        @top_path
      end

      def install_dir
        File.expand_path(File.join(ENV['HOME'], ".webdrivers")).tap {|dir| FileUtils.mkdir_p dir}
      end

      def downloads
        raise StandardError, "Can not reach site" unless site_available?

        @downloads ||= begin
          doc = Nokogiri::XML.parse(OpenURI.open_uri(base_url))
          items = doc.css("Contents Key").collect(&:text)
          items.select! {|item| item.include?('linux64')}
          items.each_with_object({}) do |item, hash|
            key = normalize item[/^[^\/]+/]
            hash[key] = "#{base_url}/#{item}"
          end
        end
      end

    end
  end
end