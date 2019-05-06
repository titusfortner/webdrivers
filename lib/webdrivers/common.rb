# frozen_string_literal: true

require 'rubygems/package'
require 'zip'
require 'webdrivers/logger'
require 'selenium-webdriver'

module Webdrivers
  class << self
    attr_accessor :proxy_addr, :proxy_port, :proxy_user, :proxy_pass, :install_dir

    def logger
      @logger ||= Webdrivers::Logger.new
    end

    def configure
      yield self
    end

    def net_http_ssl_fix
      raise 'Webdrivers.net_http_ssl_fix is no longer available.' \
      ' Please see https://github.com/titusfortner/webdrivers#ssl_connect-errors.'
    end
  end

  class Common
    class << self
      attr_accessor :version

      def update
        unless site_available?
          return current_version.nil? ? nil : binary
        end

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
          normalize_version(version)
        end
      end

      def latest_version
        return @latest_version if @latest_version

        raise StandardError, 'Can not reach site' unless site_available?

        @latest_version = downloads.keys.max
      end

      def remove
        max_attempts  = 3
        attempts_made = 0
        delay         = 0.5
        Webdrivers.logger.debug "Deleting #{binary}"
        @download_url = nil

        begin
          attempts_made += 1
          File.delete binary if File.exist? binary
        rescue Errno::EACCES # Solves an intermittent file locking issue on Windows
          sleep(delay)
          retry if File.exist?(binary) && attempts_made <= max_attempts
          raise
        end
      end

      def download
        raise StandardError, 'Can not reach site' unless site_available?

        filename = File.basename download_url

        FileUtils.mkdir_p(install_dir) unless File.exist?(install_dir)
        Dir.chdir install_dir do
          df = Tempfile.open(['', filename], binmode: true) do |file|
            file.print get(download_url)
            file
          end

          raise "Could not download #{download_url}" unless File.exist? df.to_path

          Webdrivers.logger.debug "Successfully downloaded #{df.to_path}"

          decompress_file(df.to_path, filename)
          Webdrivers.logger.debug 'Decompression Complete'
          Webdrivers.logger.debug "Deleting #{df.to_path}"
          df.close!
        end
        raise "Could not decompress #{download_url} to get #{binary}" unless File.exist?(binary)

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
        raise StandardError, 'Too many HTTP redirects' if limit.zero?

        response = http.get_response(URI(url))
        Webdrivers.logger.debug "Get response: #{response.inspect}"

        case response
        when Net::HTTPSuccess
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
          Net::HTTP.Proxy(Webdrivers.proxy_addr, Webdrivers.proxy_port,
                          Webdrivers.proxy_user, Webdrivers.proxy_pass)
        else
          Net::HTTP
        end
      end

      private

      def download_url
        @download_url ||= downloads[desired_version]
      end

      def using_proxy
        Webdrivers.proxy_addr && Webdrivers.proxy_port
      end

      def exists?
        result = File.exist? binary
        Webdrivers.logger.debug "File already exists: #{result}"
        result
      end

      def site_available?
        Webdrivers.logger.debug "Looking for Site: #{base_url}"
        get(base_url)
        Webdrivers.logger.debug "Found Site: #{base_url}"
        true
      rescue StandardError => e
        Webdrivers.logger.debug e
        false
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

      def decompress_file(filename, target)
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
          FileUtils.cp(filename, File.join(Dir.pwd, target))
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
        Zip::File.open(filename) do |zip_file|
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

      # Already have latest version?
      def correct_binary?
        desired_version == current_version && File.exist?(binary)
      end

      def normalize_version(version)
        Gem::Version.new(version.to_s)
      end
    end
  end
end
