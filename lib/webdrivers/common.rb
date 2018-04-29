require 'rubygems/package'
require 'zip'

module Webdrivers
  class Common
    class << self

      def update
        unless site_available?
          return current.nil? ? nil : binary
        end
        released      = latest()
        location      = binary()
        binary_exists = File.exists?(location)

        return location if released.nil? && binary_exists

        if released.nil?
          msg = "Unable to find the latest version of #{file_name}; try downloading manually from #{base_url} and place in #{install_dir}"
          raise StandardError, msg
        end

        if current == released && binary_exists # Already have latest/matching one
          Webdrivers.logger.debug "Expected webdriver version found"
          return location
        end

        remove if binary_exists # Remove outdated exe
        download
      end

      def latest
        downloads.keys.sort.last
      end

      def remove
        Webdrivers.logger.debug "Deleting #{binary}"
        FileUtils.rm_f binary
      end

      def download(version = nil)
        url      = download_url(version)
        filename = File.basename url

        Dir.mkdir(install_dir) unless File.exists?(install_dir)
        Dir.chdir install_dir do
          FileUtils.rm_f filename
          open(filename, "wb") do |file|
            file.print get(url)
          end
          raise "Could not download #{url}" unless File.exists? filename
          Webdrivers.logger.debug "Successfully downloaded #{filename}"
          dcf = decompress_file(filename)
          Webdrivers.logger.debug "Decompression Complete"
          if dcf
            Webdrivers.logger.debug "Deleting #{filename}"
            FileUtils.rm_f filename
          end
          if respond_to? :extract_file
            Webdrivers.logger.debug "Extracting #{dcf}"
            extract_file(dcf)
          end
        end
        raise "Could not decompress #{filename} to get #{binary}" unless File.exists?(binary)
        FileUtils.chmod "ugo+rx", binary
        Webdrivers.logger.debug "Completed download and processing of #{binary}"
        binary
      end

      protected

      def get(url, limit = 10)
        raise StandardError, 'Too many HTTP redirects' if limit == 0

        response = http.get_response(URI(url))

        case response
          when Net::HTTPSuccess then
            response.body
          when Net::HTTPRedirection
            location = response['location']
            Webdrivers.logger.debug "Redirected to #{location}"
            get(location, limit - 1)
          else
            response.value
        end
      end

      def http
        if using_proxy
          return Net::HTTP.Proxy(Webdrivers.proxy_addr, Webdrivers.proxy_port,
                                 Webdrivers.proxy_user, Webdrivers.proxy_pass)
        end
        return Net::HTTP
      end

      private

      def using_proxy
        Webdrivers.proxy_addr && Webdrivers.proxy_port
      end

      def download_url(version)
        downloads[version || latest]
      end

      def downloaded?
        result = File.exist? binary
        Webdrivers.logger.debug "File is already downloaded: #{result}"
        result
      end

      def binary
        File.join install_dir, file_name
      end

      def site_available?
        get(base_url)
        Webdrivers.logger.debug "Found Site: #{base_url}"
        true
      rescue StandardError
        Webdrivers.logger.debug "Site Not Available: #{base_url}"
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
            Webdrivers.logger.debug "Decompressing tar"
            untargz_file(filename)
          when /tar\.bz2$/
            Webdrivers.logger.debug "Decompressing bz2"
            system "tar xjf #{filename}"
            filename.gsub('.tar.bz2', '')
          when /\.zip$/
            Webdrivers.logger.debug "Decompressing zip"
            unzip_file(filename)
          else
            Webdrivers.logger.debug "No Decompression needed"
            nil
        end
      end

      def untargz_file(filename)
        tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(filename))

        File.open(file_name, "w+b") do |ucf|
          tar_extract.each { |entry| ucf << entry.read }
          File.basename ucf
        end
      end

      def unzip_file(filename)
        Zip::File.open("#{Dir.pwd}/#{filename}") do |zip_file|
          zip_file.each do |f|
            @top_path ||= f.name
            f_path    = File.join(Dir.pwd, f.name)
            FileUtils.rm_rf(f_path) if File.exist?(f_path)
            FileUtils.mkdir_p(File.dirname(f_path)) unless File.exist?(File.dirname(f_path))
            zip_file.extract(f, f_path)
          end
        end
        @top_path
      end

      def install_dir
        File.expand_path(File.join(ENV['HOME'], ".webdrivers")).tap { |dir| FileUtils.mkdir_p dir }
      end
    end
  end
end