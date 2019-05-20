# frozen_string_literal: true

require 'rubygems/package'
require 'zip'
require 'webdrivers/logger'
require 'webdrivers/network'
require 'webdrivers/system'
require 'selenium-webdriver'

module Webdrivers
  class ConnectionError < StandardError
  end

  class VersionError < StandardError
  end

  class NetworkError < StandardError
  end

  class << self
    attr_accessor :proxy_addr, :proxy_port, :proxy_user, :proxy_pass, :install_dir

    #
    # Returns the amount of time (Seconds) the gem waits between two update checks.
    #
    def cache_time
      @cache_time || 0
    end

    #
    # Set the amount of time (Seconds) the gem waits between two update checks. Disable
    # Common.cache_warning.
    #
    def cache_time=(value)
      Common.cache_warning = true
      @cache_time = value
    end

    def logger
      @logger ||= Webdrivers::Logger.new
    end

    #
    # Provides a convenient way to configure the gem.
    #
    # @example Configure proxy and cache_time
    #   Webdrivers.configure do |config|
    #     config.proxy_addr = 'myproxy_address.com'
    #     config.proxy_port = '8080'
    #     config.proxy_user = 'username'
    #     config.proxy_pass = 'password'
    #     config.cache_time = 604_800 # 7 days
    #   end
    #
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
      attr_accessor :cache_warning

      def version
        Webdrivers.logger.deprecate("#{self.class}#version", "#{self.class}#required_version")
        required_version
      end

      def version=(version)
        Webdrivers.logger.deprecate("#{self.class}#version=", "#{self.class}#required_version=")
        self.required_version = version
      end

      #
      # Returns the user defined required version.
      #
      # @return [Gem::Version]
      def required_version
        normalize_version @required_version
      end

      #
      # Triggers an update check.
      #
      # @return [String] Path to the driver binary.
      def update
        if correct_binary?
          msg = required_version != EMPTY_VERSION ?  'The required webdriver version' : 'A working webdriver version'
          Webdrivers.logger.debug "#{msg} is already on the system"
          return driver_path
        end

        remove
        System.download(download_url, driver_path)
      end

      def desired_version
        old = "#{self.class}#desired_version"
        new = "#{self.class}#required_version or #{self.class}#latest_version"
        Webdrivers.logger.deprecate(old, new)

        desired_version == EMPTY_VERSION ? latest_version : normalize_version(desired_version)
      end

      #
      # Deletes the existing driver binary.
      #
      def remove
        @download_url = nil
        @latest_version = nil
        System.delete "#{System.install_dir}/#{file_name.gsub('.exe', '')}.version"
        System.delete driver_path
      end

      def download
        Webdrivers.logger.deprecate('#download', '#update')
        System.download(download_url, driver_path)
      end

      def binary
        Webdrivers.logger.deprecate('#binary', '#driver_path')
        driver_path
      end

      #
      # Returns path to the driver binary.
      #
      # @return [String]
      def driver_path
        File.join System.install_dir, file_name
      end

      private

      def download_url
        @download_url ||= if required_version == EMPTY_VERSION
                            downloads[downloads.keys.max]
                          else
                            downloads[normalize_version(required_version)]
                          end
      end

      def exists?
        System.exists? driver_path
      end

      def correct_binary?
        current_version == if required_version == EMPTY_VERSION
                             latest_version
                           else
                             normalize_version(required_version)
                           end
      rescue ConnectionError, VersionError
        driver_path if sufficient_binary?
      end

      def sufficient_binary?
        exists?
      end

      def normalize_version(version)
        Gem::Version.new(version.to_s)
      end

      def binary_version
        version = System.call("#{driver_path} --version")
        Webdrivers.logger.debug "Current version of #{driver_path} is #{version}"
        version
      rescue Errno::ENOENT
        Webdrivers.logger.debug "No Such File or Directory: #{driver_path}"
        nil
      end

      def with_cache(file_name)
        if System.valid_cache?(file_name)
          normalize_version System.cached_version(file_name)
        else
          unless Common.cache_warning
            Webdrivers.logger.warn 'Driver caching is turned off in this version, but will be '\
                                  'enabled by default in 4.x. Set the value with `Webdrivers#cache_time=` in seconds'
            Common.cache_warning = true
          end
          version = yield
          System.cache_version(file_name, version)
          normalize_version version
        end
      end

      EMPTY_VERSION = Gem::Version.new('')
    end
  end
end
