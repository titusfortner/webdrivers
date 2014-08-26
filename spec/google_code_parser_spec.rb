require "spec_helper"

describe Chromedriver::Helper::GoogleCodeParser do
  before(:each) do
    Chromedriver::Helper::GoogleCodeParser.any_instance.stub(:open).and_return(File.read(File.join(File.dirname(__FILE__), "assets/google-code-bucket.xml")))
  end
  let!(:parser) { Chromedriver::Helper::GoogleCodeParser.new('mac') }

  describe "#downloads" do
    it "returns an array of URLs for the platform" do
      parser.downloads.should == [
        "http://chromedriver.storage.googleapis.com/2.0/chromedriver_mac32.zip",
        "http://chromedriver.storage.googleapis.com/2.1/chromedriver_mac32.zip",
        "http://chromedriver.storage.googleapis.com/2.2/chromedriver_mac32.zip",
        "http://chromedriver.storage.googleapis.com/2.3/chromedriver_mac32.zip",
        "http://chromedriver.storage.googleapis.com/2.4/chromedriver_mac32.zip"]
    end
  end

  describe "#newest_download" do
    it "returns the last URL for the platform" do
      parser.newest_download.should == "http://chromedriver.storage.googleapis.com/2.4/chromedriver_mac32.zip"
    end
  end
end

