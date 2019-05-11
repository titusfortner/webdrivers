# frozen_string_literal: true

require 'rubygems/package'
require 'zip'

module Webdrivers
  #
  # @api private
  #
  class System
    class << self
      def delete(file)
        max_attempts = 3
        attempts_made = 0
        delay = 0.5
        Webdrivers.logger.debug "Deleting #{file}"

        begin
          attempts_made += 1
          File.delete file if File.exist? file
        rescue Errno::EACCES # Solves an intermittent file locking issue on Windows
          sleep(delay)
          retry if File.exist?(file) && attempts_made <= max_attempts
          raise
        end
      end

      def install_dir
        Webdrivers.install_dir || File.expand_path(File.join(ENV['HOME'], '.webdrivers'))
      end

      def cache_version(file_name, version)
        FileUtils.mkdir_p(install_dir) unless File.exist?(install_dir)

        File.open("#{install_dir}/#{file_name.gsub('.exe', '')}.version", 'w+') do |file|
          file.print(version)
        end
      end

      def cached_version(file_name)
        File.open("#{install_dir}/#{file_name.gsub('.exe', '')}.version", 'r', &:read)
      end

      def valid_cache?(file_name)
        file = "#{install_dir}/#{file_name.gsub('.exe', '')}.version"
        return false unless File.exist?(file)

        Time.now - File.mtime(file) < Webdrivers.cache_time
      end

      def download(url, target)
        FileUtils.mkdir_p(install_dir) unless File.exist?(install_dir)

        download_file(url, target)

        FileUtils.chmod 'ugo+rx', target
        Webdrivers.logger.debug "Completed download and processing of #{target}"
        target
      end

      def download_file(url, target)
        file_name = File.basename(url)
        Dir.chdir(install_dir) do
          tempfile = Tempfile.open(['', file_name], binmode: true) do |file|
            file.print Network.get(url)
            file
          end

          raise "Could not download #{url}" unless File.exist?(tempfile.to_path)

          Webdrivers.logger.debug "Successfully downloaded #{tempfile.to_path}"

          decompress_file(tempfile, file_name, target)
          tempfile.close!
        end
      end

      def exists?(file)
        result = File.exist? file
        Webdrivers.logger.debug "#{file} is#{' not' unless result} already downloaded"
        result
      end

      def decompress_file(tempfile, file_name, target)
        tempfile = tempfile.to_path
        case tempfile
        when /tar\.gz$/
          untargz_file(tempfile, File.basename(target))
        when /tar\.bz2$/
          untarbz2_file(tempfile)
        when /\.zip$/
          unzip_file(tempfile)
        else
          Webdrivers.logger.debug 'No Decompression needed'
          FileUtils.cp(tempfile, File.join(Dir.pwd, file_name))
        end
        raise "Could not decompress #{file_name} to get #{target}" unless File.exist?(File.basename(target))
      end

      def untarbz2_file(filename)
        Webdrivers.logger.debug "Decompressing #{filename}"

        call("tar xjf #{filename}").gsub('.tar.bz2', '')
      end

      def untargz_file(source, target)
        Webdrivers.logger.debug "Decompressing #{source}"

        tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(source))

        File.open(target, 'w+b') do |ucf|
          tar_extract.each { |entry| ucf << entry.read }
          File.basename ucf
        end
      end

      def unzip_file(filename)
        Webdrivers.logger.debug "Decompressing #{filename}"

        Zip::File.open(filename) do |zip_file|
          zip_file.each do |f|
            @top_path ||= f.name
            f_path = File.join(Dir.pwd, f.name)
            delete(f_path)
            FileUtils.mkdir_p(File.dirname(f_path)) unless File.exist?(File.dirname(f_path))
            zip_file.extract(f, f_path)
          end
        end
        @top_path
      end

      def platform
        if Selenium::WebDriver::Platform.linux?
          'linux'
        elsif Selenium::WebDriver::Platform.mac?
          'mac'
        elsif Selenium::WebDriver::Platform.windows?
          'win'
        else
          raise NotImplementedError, 'Your OS is not supported by webdrivers gem.'
        end
      end

      def bitsize
        Selenium::WebDriver::Platform.bitsize
      end

      def call(cmd)
        Webdrivers.logger.debug "making System call: #{cmd}"
        `#{cmd}`
      end
    end
  end
end
