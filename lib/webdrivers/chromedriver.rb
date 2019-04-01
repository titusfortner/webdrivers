require 'nokogiri'
require 'shellwords'

module Webdrivers
  class Chromedriver < Common
    class << self
      def current_version
        Webdrivers.logger.debug 'Checking current version'
        return nil unless downloaded?

        ver = `#{binary} --version`
        Webdrivers.logger.debug "Current #{binary} version: #{ver}"

        # Matches 2.46, 2.46.628411 and 73.0.3683.75
        normalize ver[/\d+\.\d+(\.\d+)?(\.\d+)?/]
      end

      def latest_version
        unless site_available?
          cur_ver = current_version
          raise StandardError, update_failed_msg if cur_ver.nil? # Site is down and no existing binary

          Webdrivers.logger.warn "Can not reach update site. Using existing #{file_name} #{cur_ver}"
          return cur_ver
        end

        # Versions before 70 do not have a LATEST_RELEASE file
        return Gem::Version.new('2.46') if release_version < '70.0.3538'

        # Latest webdriver release for installed Chrome version
        release_file     = "LATEST_RELEASE_#{release_version}"
        latest_available = get(URI.join(base_url, release_file))
        Webdrivers.logger.debug "Latest version available: #{latest_available}"
        Gem::Version.new(latest_available)
      end

      private

      def file_name
        platform == 'win' ? 'chromedriver.exe' : 'chromedriver'
      end

      def base_url
        'https://chromedriver.storage.googleapis.com'
      end

      def downloads
        Webdrivers.logger.debug "Versions previously located on downloads site: #{@downloads.keys}" if @downloads

        @downloads ||= begin
          doc   = Nokogiri::XML.parse(get(base_url))
          items = doc.css('Contents Key').collect(&:text)
          items.select! { |item| item.include?(platform) }
          ds = items.each_with_object({}) do |item, hash|
            key       = normalize item[%r{^[^/]+}]
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

        raise StandardError, 'Failed to find Chrome binary or its version.' if ver.nil? || ver.empty?

        # Google Chrome 73.0.3683.75 -> 73.0.3683.75
        ver[/\d+\.\d+\.\d+\.\d+/]
      end

      def chrome_on_windows
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return `powershell (Get-ItemProperty '#{browser_binary}').VersionInfo.ProductVersion`.strip
        end

        # Workaround for Google Chrome when using Jruby on Windows.
        # @see https://github.com/titusfortner/webdrivers/issues/41
        if RUBY_PLATFORM == 'java'
          ver = 'powershell (Get-Item -Path ((Get-ItemProperty "HKLM:\\Software\\Microsoft' \
          "\\Windows\\CurrentVersion\\App` Paths\\chrome.exe\").\\'(default)\\'))" \
          '.VersionInfo.ProductVersion'
          return `#{ver}`.strip
        end

        # Default to Google Chrome
        reg        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'
        executable = `powershell (Get-ItemProperty '#{reg}' -Name '(default)').'(default)'`.strip
        Webdrivers.logger.debug "Browser executable: '#{executable}'"
        ps = "(Get-Item (Get-ItemProperty '#{reg}').'(default)').VersionInfo.ProductVersion"
        `powershell #{ps}`.strip
      end

      def chrome_on_linux
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return `#{Shellwords.escape browser_binary} --product-version`.strip
        end

        # Default to Google Chrome
        executable = `which google-chrome`.strip
        Webdrivers.logger.debug "Browser executable: '#{executable}'"
        `#{executable} --product-version`.strip
      end

      def chrome_on_mac
        if browser_binary
          Webdrivers.logger.debug "Browser executable: '#{browser_binary}'"
          return `#{Shellwords.escape browser_binary} --version`.strip
        end

        # Default to Google Chrome
        executable = Shellwords.escape '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
        Webdrivers.logger.debug "Browser executable: #{executable}"
        `#{executable} --version`.strip
      end

      #
      # Returns user defined browser executable path from Selenium::WebDrivers::Chrome#path.
      #
      def browser_binary
        # For Chromium, Brave, or whatever else
        Selenium::WebDriver::Chrome.path
      end
    end
  end
end
