require 'rubygems/package'
require 'zip'

module Webdrivers
  class Common
    class << self
      attr_accessor :version

      def update
        if correct_binary? # Already have desired or latest version
          Webdrivers.logger.debug 'Expected webdriver version found'
          return binary
        end

        # If site is down
        unless site_available?
          # No existing binary and we can't download
          raise StandardError, update_failed_msg if current_version.nil?

          # Use existing binary
          Webdrivers.logger.error "Can not reach update site. Using existing #{file_name} #{current_version}"
          return binary
        end

        # Newer not specified or latest not found, so use existing
        return binary if desired_version.nil? && File.exist?(binary)

        # Can't find desired and no existing binary
        raise StandardError, update_failed_msg if desired_version.nil?

        remove # Remove outdated exe
        download # Fetch desired or latest
      end

      def desired_version
        ver = if version.is_a?(Gem::Version)
                version
              elsif version.nil?
                latest_version
              else
                Gem::Version.new(version.to_s)
              end

        Webdrivers.logger.debug "Desired version: #{ver}"
        ver
      end

      def latest_version
        unless site_available?
          cur_ver = current_version
          raise StandardError, update_failed_msg if cur_ver.nil? # Site is down and no existing binary

          Webdrivers.logger.error "Can not reach update site. Using existing #{file_name} #{cur_ver}"
          return cur_ver
        end

        downloads.keys.max
      end

      def remove
        Webdrivers.logger.debug "Deleting #{binary}"
        FileUtils.rm_f binary
      end

      def download
        raise StandardError, update_failed_msg unless site_available?

        url = downloads[desired_version]
        Webdrivers.logger.debug "Downloading #{url}"
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

      #
      # Returns count of network request made to the base url. Used for debugging
      # purpose only.
      #
      def network_requests
        @network_requests || 0
      end

      #
      # Resets network request count to 0.
      #
      def reset_network_requests
        @network_requests = 0
      end

      protected

      def get(url, limit = 10)
        raise StandardError, 'Too many HTTP redirects' if limit.zero?

        @network_requests ||= 0
        response = http.get_response(URI(url))
        Webdrivers.logger.debug "Get response: #{response.inspect}"
        @network_requests += 1
        Webdrivers.logger.debug "Successful network request ##{@network_requests}"

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

      def using_proxy
        Webdrivers.proxy_addr && Webdrivers.proxy_port
      end

      def downloaded?
        result = File.exist? binary
        Webdrivers.logger.debug "File is already downloaded: #{result}"
        result
      end

      def site_available?
        Webdrivers.logger.debug "Looking for Site: #{base_url}"
        get(base_url)
        Webdrivers.logger.debug "Found Site: #{base_url}"
        true
      rescue StandardError => ex
        Webdrivers.logger.debug ex.inspect
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

      def update_failed_msg
        "Update site is unreachable. Try downloading '#{file_name}' manually from " \
          "#{base_url} and place in '#{install_dir}'"
      end
    end
  end
end
