require "spec_helper"

describe Webdrivers::Edgedriver do

  let(:edgedriver) { Webdrivers::Edgedriver }

  it 'downloads' do
    allow(edgedriver).to receive(:newest_version).and_return(0)
    edgedriver.download
    file = "#{edgedriver.platform_install_dir}/MicrosoftWebDriver.exe"
    expect(File.exist?(file)).to eq true
    FileUtils.rm(file)
  end

  it 'gets latest version' do
    skip unless edgedriver.platform == 'win'
    expect(edgedriver.newest_version.to_f).to be >= 2.25
  end

  context "on a windows platform" do
    before { allow(edgedriver).to receive(:platform) { "win" } }

    it { expect(edgedriver.file_name).to match(/MicrosoftWebDriver\.exe$/) }

    it { expect(edgedriver.binary_path).to match '.webdrivers/win/MicrosoftWebDriver.exe' }

  end
end
