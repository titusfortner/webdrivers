require 'nokogiri'

module Webdrivers
  class Chromedriver < Common
    class << self

      def current_version
        Webdrivers.logger.debug "Checking current version"
        return nil unless downloaded?
        string = %x(#{binary} --version)
        Webdrivers.logger.debug "Current version of #{binary} is #{string}"
        normalize string.match(/ChromeDriver (\d+\.\d+)/)[1]
      end

      def latest_version
        raise StandardError, "Can not reach site" unless site_available?

        # Latest webdriver release for installed Chrome version
        release_file     = "LATEST_RELEASE_#{release_version}"
        latest_available = get(URI.join(base_url, release_file))
        Gem::Version.new(latest_available)
      end

      private

      def file_name
        platform == "win" ? "chromedriver.exe" : "chromedriver"
      end

      def base_url
        'https://chromedriver.storage.googleapis.com'
      end

      def downloads
        Webdrivers.logger.debug "Versions previously located on downloads site: #{@downloads.keys}" if @downloads

        @downloads ||= begin
          doc   = Nokogiri::XML.parse(get(base_url))
          items = doc.css("Contents Key").collect(&:text)
          items.select! { |item| item.include?(platform) }
          ds = items.each_with_object({}) do |item, hash|
            key       = normalize item[/^[^\/]+/]
            hash[key] = "#{base_url}/#{item}"
          end
          Webdrivers.logger.debug "Versions now located on downloads site: #{ds.keys}"
          ds
        end
      end

      # Returns release version from the currently installed Chrome version
      #
      # @example
      #   73.0.3683.75 -> 73.0.3683
      def release_version
        chrome_version[/\d+\.\d+\.\d+/]
      end

      # Returns currently installed Chrome version
      def chrome_version
        ver = case platform
                when 'win'
                  chrome_on_windows
                when /linux/
                  chrome_on_linux
                when 'mac'
                  chrome_on_mac
                else
                  raise NotImplementedError, 'Your OS is not supported by webdrivers gem.'
              end.chomp

        # Google Chrome 73.0.3683.75 -> 73.0.3683.75
        ver[/(\d|\.)+/]
      end

      def chrome_on_windows
        reg = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'
        ps  = "(Get-Item (Get-ItemProperty '#{reg}').'(Default)').VersionInfo.ProductVersion"
        `powershell #{ps}`
      end

      def chrome_on_linux
        `#{ENV['GOOGLE_CHROME_BIN'] || 'google-chrome'} --version`
      end

      def chrome_on_mac
        loc = Shellwords.escape '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
        `#{loc} --version`
      end
    end
  end
end
