require 'rubygems/package'
require 'zip'

module Webdrivers
  class Common

    class << self
      def install *args
        download
        exec binary_path, *args
      end

      def download
        return if File.exists?(binary_path) && !internet_connection?
        raise StandardError, "Unable to Reach #{base_url}" unless internet_connection?
        return if newest_version == current_version

        url = download_url
        filename = File.basename url
        Dir.chdir platform_install_dir do
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
        raise "Could not unzip #{filename} to get #{binary_path}" unless File.exists? binary_path
        FileUtils.chmod "ugo+rx", binary_path
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
        tar_extract.each { |entry| ucf << entry.read }
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

      def download_url(version = nil)
        downloads[version || newest_version]
      end

      def binary_path
        File.join platform_install_dir, file_name
      end

      def platform_install_dir
        File.join(install_dir, platform).tap { |dir| FileUtils.mkdir_p dir }
      end

      def install_dir
        File.expand_path(File.join(ENV['HOME'], ".webdrivers")).tap { |dir| FileUtils.mkdir_p dir }
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

      def internet_connection?
        true #if open(base_url)
      rescue
        false
      end
    end

  end
end