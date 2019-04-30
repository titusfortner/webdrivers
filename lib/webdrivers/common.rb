# frozen_string_literal: true

require 'rubygems/package'
require 'zip'

module Webdrivers
  class Common
    class << self
      attr_accessor :version

      def update
        # Newer not specified or latest not found, so use existing
        return binary if desired_version.nil? && File.exist?(binary)

        # Can't find desired and no existing binary
        if desired_version.nil?
          msg = "Unable to find the latest version of #{file_name}; try downloading manually " \
"from #{base_url} and place in #{install_dir}"
          raise StandardError, msg
        end

        if correct_binary?
          Webdrivers.logger.debug 'Expected webdriver version found'
          return binary
        end

        remove # Remove outdated exe
        download # Fetch latest
      end

      def desired_version
        if version.is_a?(Gem::Version)
          version
        elsif version.nil?
          latest_version
        else
          Gem::Version.new(version.to_s)
        end
      end

      def latest_version
        @latest_version ||= downloads.keys.max
      end

      def remove
        Webdrivers.logger.debug "Deleting #{binary}"
        FileUtils.rm_f binary
      end

      def download
        url = downloads[desired_version]
        filename = File.basename url

        FileUtils.mkdir_p(install_dir) unless File.exist?(install_dir)
        Dir.chdir install_dir do
          FileUtils.rm_f filename
          File.open(filename, 'wb') do |file|
            file.print get(url)
          end
          raise "Could not download #{url}" unless File.exist? filename

          Webdrivers.logger.debug "Successfully downloaded #{filename}"
          dcf = decompress_file(filename)
          Webdrivers.logger.debug 'Decompression Complete'
          if dcf
            Webdrivers.logger.debug "Deleting #{filename}"
            FileUtils.rm_f filename
          end
          if respond_to? :extract_file
            Webdrivers.logger.debug "Extracting #{dcf}"
            extract_file(dcf)
          end
        end
        raise "Could not decompress #{filename} to get #{binary}" unless File.exist?(binary)

        FileUtils.chmod 'ugo+rx', binary
        Webdrivers.logger.debug "Completed download and processing of #{binary}"
        binary
      end

      def install_dir
        Webdrivers.install_dir || File.expand_path(File.join(ENV['HOME'], '.webdrivers'))
      end

      def binary
        File.join install_dir, file_name
      end

      protected

      def get(url, limit = 10)
        Webdrivers.logger.debug "Getting URL: #{url}"

        raise StandardError, 'Too many HTTP redirects' if limit.zero?

        begin
          response = http.get_response(URI(url))
        rescue SocketError
          raise StandardError, "Can not reach #{url}"
        end

        Webdrivers.logger.debug "Get response: #{response.inspect}"

        case response
        when Net::HTTPSuccess
          response.body
        when Net::HTTPRedirection
          location = response['location']
          Webdrivers.logger.debug "Redirected to URL: #{location}"
          get(location, limit - 1)
        else
          response.value
        end
      end

      def http
        if using_proxy
          Net::HTTP.Proxy(Webdrivers.proxy_addr, Webdrivers.proxy_port,
                          Webdrivers.proxy_user, Webdrivers.proxy_pass)
        else
          Net::HTTP
        end
      end

      private

      def using_proxy
        Webdrivers.proxy_addr && Webdrivers.proxy_port
      end

      def downloaded?
        result = File.exist? binary
        Webdrivers.logger.debug "File is already downloaded: #{result}"
        result
      end

      def platform
        if Selenium::WebDriver::Platform.linux?
          "linux#{Selenium::WebDriver::Platform.bitsize}"
        elsif Selenium::WebDriver::Platform.mac?
          'mac'
        else
          'win'
        end
      end

      def decompress_file(filename)
        case filename
        when /tar\.gz$/
          Webdrivers.logger.debug 'Decompressing tar'
          untargz_file(filename)
        when /tar\.bz2$/
          Webdrivers.logger.debug 'Decompressing bz2'
          system "tar xjf #{filename}"
          filename.gsub('.tar.bz2', '')
        when /\.zip$/
          Webdrivers.logger.debug 'Decompressing zip'
          unzip_file(filename)
        else
          Webdrivers.logger.debug 'No Decompression needed'
          nil
        end
      end

      def untargz_file(filename)
        tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(filename))

        File.open(file_name, 'w+b') do |ucf|
          tar_extract.each { |entry| ucf << entry.read }
          File.basename ucf
        end
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

      # Already have latest version downloaded?
      def correct_binary?
        desired_version == current_version && File.exist?(binary)
      end

      def normalize(string)
        Gem::Version.new(string)
      end
    end
  end
end
