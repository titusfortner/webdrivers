require 'rubygems/package'
require 'nokogiri'
require 'open-uri'
require 'zip'

module Webdrivers
  class Common
    class << self

      def update
        unless site_available?
          return current.nil? ? nil : binary
        end
        return binary if current == latest
        remove && download
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

      def downloaded?
        File.exist? binary
      end

      def binary
        File.join install_dir, file_name
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
    end
  end
end