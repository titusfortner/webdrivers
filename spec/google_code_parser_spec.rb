require "spec_helper"

describe Chromedriver::Helper::GoogleCodeParser do
  describe ".new" do
    it "takes HTML" do
      html = "<html><body><div>hello</div></body></html>"
      parser = Chromedriver::Helper::GoogleCodeParser.new html
      parser.html.should == html
    end
  end

  describe "#downloads" do
    it "returns a hash of names and urls" do
      parser = Chromedriver::Helper::GoogleCodeParser.new File.read(File.join(File.dirname(__FILE__), "assets/google-code.html"))
      parser.downloads.should == [
        "//chromedriver.googlecode.com/files/chromedriver_linux32_2.3.zip",
        "//chromedriver.googlecode.com/files/chromedriver_mac32_2.3.zip",
        "//chromedriver.googlecode.com/files/chromedriver_linux64_2.3.zip",
        "//chromedriver.googlecode.com/files/release_notes_2.3.txt",
        "//chromedriver.googlecode.com/files/chromedriver_win32_2.3.zip",
      ]
    end
  end
end

