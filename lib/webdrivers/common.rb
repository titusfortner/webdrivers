# frozen_string_literal: true

require 'rubygems/package'
require 'zip'

module Webdrivers
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
        normalize_version @required_version
      end

      def update
        if correct_binary?
          Webdrivers.logger.debug 'The desired webdriver version is already on the system'
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

      def downloaded?
        System.downloaded? driver_path
      end

      # Already have correct version on the system?
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
        downloaded?
      end

      def normalize_version(version)
        Gem::Version.new(version.nil? ? nil : version.to_s)
      end

      def binary_version
        version = System.call("#{driver_path} --version")
        Webdrivers.logger.debug "Current version of #{driver_path} is #{version}"
        version
      rescue Errno::ENOENT
        nil
      end
    end
  end
end
