module Webdrivers
  class MSWebdriver < Common
    class << self

      def current
        Webdrivers.logger.debug "Checking current version"

        # current() from other webdrivers returns the version from the webdriver EXE.
        # Unfortunately, MicrosoftWebDriver.exe does not have an option to get the version.
        # To work around it we query the currently installed version of Microsoft Edge instead
        # and compare it to the list of available downloads.
        version = `powershell (Get-AppxPackage -Name Microsoft.MicrosoftEdge).Version`
        raise "Failed to check Microsoft Edge version." if version.blank? # Package name changed?
        Webdrivers.logger.debug "Current version of Microsoft Edge is #{version.chomp!}"

        build   = version.split('.')[1] # "41.16299.248.0" => "16299"
        Webdrivers.logger.debug "Expecting MicrosoftWebDriver.exe version #{build}"
        build.to_i
      end

      private

      def normalize(string)
        string.match(/(\d+)\.(\d+\.\d+)/).to_a.map {|v| v.tr('.', '')}[1..-1].join('.').to_f
      end

      def file_name
        "MicrosoftWebDriver.exe"
      end

      def downloads
        raise StandardError, "Can not reach site" unless site_available?
        array = Nokogiri::HTML(get(download_page)).xpath("//li[@class='driver-download']/a")
        array.each_with_object({}) do |link, hash|
          next if link.text == 'Insiders'
          hash[link.text.scan(/\d+/).first.to_i] = link['href']
        end
      end

      def base_url
        'https://www.microsoft.com/en-us/download'
      end

       # Using this as base_url yields Net::HTTPRedirection with a partial location, which fails
       # on the second Common#get call in lib/webdrivers/common.rb:77.
       # Using existing base_url to get past that hurdle until we discuss a better way to handle
       # the HTTP status.
      def download_page
        "https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/"
      end

    end
  end
end