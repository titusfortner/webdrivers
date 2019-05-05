# frozen_string_literal: true

require 'rubygems/package'
require 'zip'
require 'webdrivers/logger'
require 'selenium-webdriver'

module Webdrivers
  class ConnectionError < StandardError
  end

  class VersionError < StandardError
  end

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
      attr_writer :required_version

      def version
        Webdrivers.logger.deprecate("#{self.class}#version", "#{self.class}#required_version")
        required_version
      end

      def version=(version)
        Webdrivers.logger.deprecate("#{self.class}#version=", "#{self.class}#required_version=")
        self.required_version = version
      end

      def required_version
        Gem::Version.new @required_version
      end

      def update
        if correct_binary?
          Webdrivers.logger.debug 'The required webdriver version is already on the system'
          return driver_path
        end

        remove
        private_download
      end

      def desired_version
        old = "#{self.class}#desired_version"
        new = "#{self.class}#required_version or #{self.class}#latest_version"
        Webdrivers.logger.deprecate(old, new)

        desired_version.version.empty? ? latest_version : normalize_version(desired_version)
      end

      def latest_version
        @latest_version ||= downloads.keys.max
      end

      def remove
        max_attempts = 3
        attempts_made = 0
        delay = 0.5
        Webdrivers.logger.debug "Deleting #{driver_path}"
        @download_url = nil
        @latest_version = nil

        begin
          attempts_made += 1
          File.delete driver_path if File.exist? driver_path
        rescue Errno::EACCES # Solves an intermittent file locking issue on Windows
          sleep(delay)
          retry if File.exist?(driver_path) && attempts_made <= max_attempts
          raise
        end
      end

      def download
        Webdrivers.logger.deprecate('#download', '#update')
        private_download
      end

      def install_dir
        Webdrivers.install_dir || File.expand_path(File.join(ENV['HOME'], '.webdrivers'))
      end

      def binary
        Webdrivers.logger.deprecate('#binary', '#driver_path')
        driver_path
      end

      def driver_path
        File.join install_dir, file_name
      end

      private

      # Rename this when deprecating #download as a public method
      def private_download
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
        raise "Could not decompress #{download_url} to get #{driver_path}" unless File.exist?(driver_path)

        FileUtils.chmod 'ugo+rx', driver_path
        Webdrivers.logger.debug "Completed download and processing of #{driver_path}"
        driver_path
      end

      def get(url, limit = 10)
        Webdrivers.logger.debug "Getting URL: #{url}"

        raise ConnectionError, 'Too many HTTP redirects' if limit.zero?

        begin
          response = http.get_response(URI(url))
        rescue SocketError
          raise ConnectionError, "Can not reach #{url}"
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

      def download_url
        @download_url ||= if required_version.version.empty?
                            downloads[downloads.keys.max]
                          else
                            downloads[normalize_version(required_version)]
                          end
      end

      def using_proxy
        Webdrivers.proxy_addr && Webdrivers.proxy_port
      end

      def exists?
        result = File.exist? driver_path
        Webdrivers.logger.debug "File already exists: #{result}"
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

      def correct_binary?
        current_version == if required_version.version.empty?
                             latest_version
                           else
                             normalize_version(required_version)
                           end
      rescue ConnectionError
        driver_path if sufficient_binary?
      end

      def sufficient_binary?
        exists?
      end

      def normalize_version(version)
        Gem::Version.new(version.to_s)
      end

      def binary_version
        version = system_call("#{driver_path} --version")
        Webdrivers.logger.debug "Current version of #{driver_path} is #{version}"
        version
      rescue Errno::ENOENT
        Webdrivers.logger.debug "No Such File or Directory: #{driver_path}"
        nil
      end

      def system_call(call)
        Webdrivers.logger.debug "making System call: #{call}"
        `#{call}`
      end
    end
  end
end
