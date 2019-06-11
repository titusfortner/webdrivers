# frozen_string_literal: true

module Webdrivers
  class EdgeFinder
    class << self
      def version
        location = Selenium::WebDriver::EdgeChrome.path || send("#{System.platform}_location")
        version = send("#{System.platform}_version", System.escape_path(location)) if location

        raise VersionError, 'Failed to find Edge binary or its version.' if version.nil? || version.empty?

        Webdrivers.logger.debug "Browser version: #{version}"
        version[/\d+\.\d+\.\d+\.\d+/] # Microsoft Edge 73.0.3683.75 -> 73.0.3683.75
      end

      def win_location
        envs = %w[LOCALAPPDATA PROGRAMFILES PROGRAMFILES(X86)]
        directories = ['\\Microsoft\\Edge SxS\\Application', '\\Microsoft\\Edge Dev\\Application']
        file = 'msedge.exe'

        directories.each do |dir|
          envs.each do |root|
            option = "#{ENV[root]}\\#{dir}\\#{file}"
            next unless File.exist?(option)

            # Escape space and parenthesis with backticks.
            option = option.gsub(/([\s()])/, '`\1') if RUBY_PLATFORM == 'java'

            return option
          end
        end
        nil
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
        nil
      end

      def linux_location
        raise 'Default location not yet known'
      end

      def win_version(location)
        System.call("powershell (Get-ItemProperty '#{location}').VersionInfo.ProductVersion")&.strip
      end

      def linux_version(location)
        System.call("#{location} --product-version")&.strip
      end

      def mac_version(location)
        System.call("#{location} --version")&.strip
      end
    end
  end
end
