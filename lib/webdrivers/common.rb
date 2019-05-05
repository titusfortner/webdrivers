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

  class << self
    attr_accessor :proxy_addr, :proxy_port, :proxy_user, :proxy_pass, :install_dir

    attr_writer :cache_time

    def cache_time
      @cache_time || 0
    end

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
      attr_reader :cache_warning

      def version
        Webdrivers.logger.deprecate("#{self.class}#version", "#{self.class}#required_version")
        required_version
      end

      def version=(version)
        Webdrivers.logger.deprecate("#{self.class}#version=", "#{self.class}#required_version=")
        self.required_version = version
      end

      def required_version
        normalize_version @required_version
      end

      def update
        if correct_binary?
          Webdrivers.logger.debug 'The required webdriver version is already on the system'
          return driver_path
        end

        remove
        System.download(download_url, driver_path)
      end

      def desired_version
        old = "#{self.class}#desired_version"
        new = "#{self.class}#required_version or #{self.class}#latest_version"
        Webdrivers.logger.deprecate(old, new)

        desired_version.version.empty? ? latest_version : normalize_version(desired_version)
      end

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

      def driver_path
        File.join System.install_dir, file_name
      end

      private

      def download_url
        @download_url ||= if required_version.version.empty?
                            downloads[downloads.keys.max]
                          else
                            downloads[normalize_version(required_version)]
                          end
      end

      def exists?
        System.exists? driver_path
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
        Gem::Version.new(version&.to_s)
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
          unless cache_warning
            Webdrivers.logger.warn 'Driver caching is turned off in this version, but will be '\
                                  'enabled by default in 4.x. Set the value with `Webdrivers#cache_time=` in seconds'
            @cache_warning = true
          end
          version = yield
          System.cache_version(file_name, version)
          normalize_version version
        end
      end
    end
  end
end
