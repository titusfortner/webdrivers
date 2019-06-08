# frozen_string_literal: true

module Webdrivers
  class EdgeFinder
    class << self
      def version
        location = Selenium::WebDriver::EdgeChrome.path || send("#{System.platform}_location")
        version = send("#{System.platform}_version", location)

        raise VersionError, 'Failed to find Edge binary or its version.' if version.nil? || version.empty?

        Webdrivers.logger.debug "Browser version: #{version}"
        version[/\d+\.\d+\.\d+\.\d+/] # Microsoft Edge 73.0.3683.75 -> 73.0.3683.75
      end

      def win_location
        return Selenium::WebDriver::Edge.path unless Selenium::WebDriver::Edge.path.nil?

        # TODO: Need to figure out what these are
        raise 'Not yet implemented'
        # envs = %w[LOCALAPPDATA PROGRAMFILES PROGRAMFILES(X86)]
        # directories = ['\\Google\\Chrome\\Application', '\\Chromium\\Application']
        # file = 'chrome.exe'
        #
        # directories.each do |dir|
        #   envs.each do |root|
        #     option = "#{ENV[root]}\\#{dir}\\#{file}"
        #     return option if File.exist?(option)
        #   end
        # end
      end

      def mac_location
        directories = ['', File.expand_path('~')]
        files = ['/Applications/Microsoft Edge Canary.app/Contents/MacOS/Microsoft Edge Canary',
                 '/Applications/Microsoft Edge Dev.app/Contents/MacOS/Microsoft Edge Dev',
                 '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge']

        directories.each do |dir|
          files.each do |file|
            option = "#{dir}/#{file}"
            return option if File.exist?(option)
          end
        end
      end

      def linux_location
        raise 'Default location not yet known'
      end

      def win_version(location)
        System.call("powershell (Get-ItemProperty '#{location}').VersionInfo.ProductVersion")&.strip
      end

      def linux_version(location)
        System.call("#{Shellwords.escape location} --product-version")&.strip
      end

      def mac_version(location)
        System.call("#{Shellwords.escape location} --version")&.strip
      end
    end
  end
end
