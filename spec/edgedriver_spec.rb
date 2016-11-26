require "spec_helper"

describe Webdrivers::Edgedriver do

  let(:edgedriver) { Webdrivers::Edgedriver }

  it 'downloads' do
    edgedriver.download
    file = "#{ENV['GEM_HOME']}/bin/MicrosoftWebDriver"
    expect(File.exist?(file)).to eq true
  end

  it { expect(edgedriver.newest_version.to_f).to be >= 2.25 }


  context "on a windows platform" do
    before { allow(edgedriver).to receive(:platform) { "win" } }

    it { expect(edgedriver.file_name).to match(/MicrosoftWebDriver\.exe$/) }

    it { expect(edgedriver.binary_path).to match '.webdrivers/win/MicrosoftWebDriver.exe' }

  end
end
