require "spec_helper"

describe Webdrivers::Geckodriver do

  let(:geckodriver) { Webdrivers::Geckodriver }

  it 'downloads' do
    geckodriver.download
    suffix = geckodriver.platform == 'win' ? '.exe' : ''
    file = "#{geckodriver.platform_install_dir}/geckodriver#{suffix}"
    expect(File.exist?(file)).to eq true
    FileUtils.rm(file)
  end

  it { expect(geckodriver.newest_version.to_f).to be >= 0.11 }

  it { expect(geckodriver.downloads.size).to be >= 4 }

  context "on a linux platform" do
    before { allow(geckodriver).to receive(:platform) { "linux32" } }

    it { expect(geckodriver.file_name).to match(/geckodriver$/) }

    it { expect(geckodriver.binary_path).to match '.webdrivers/linux32/geckodriver' }

    it { expect(geckodriver.download_url('0.11.0')).to match("v0.11.0/geckodriver-v0.11.0-linux32.tar.gz") }
  end

  context "on a windows platform" do
    before { allow(geckodriver).to receive(:platform) { "win" } }

    it { expect(geckodriver.file_name).to match(/geckodriver\.exe$/) }

    it { expect(geckodriver.binary_path).to match '.webdrivers/win/geckodriver' }

    it { expect(geckodriver.download_url('0.9.0')).to match("v0.9.0/geckodriver-v0.9.0-win64.zip") }
  end
end
