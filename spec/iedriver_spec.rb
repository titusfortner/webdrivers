require "spec_helper"

describe Webdrivers::IEDriver do

  let(:iedriver) { Webdrivers::IEDriver }

  it 'downloads' do
    allow(iedriver).to receive(:current_version).and_return(0)
    iedriver.download
    file = "#{iedriver.platform_install_dir}/IEDriverServer.exe"
    expect(File.exist?(file)).to eq true
    FileUtils.rm(file)
  end

  it { expect(iedriver.newest_version.to_f).to be >= 2.25 }


  context "on a windows platform" do
    before { allow(iedriver).to receive(:platform) { "win" } }

    it { expect(iedriver.downloads.size).to be >= 16 }

    it { expect(iedriver.file_name).to match(/IEDriverServer\.exe$/) }

    it { expect(iedriver.binary_path).to match '.webdrivers/win/IEDriverServer.exe' }

    it { expect(iedriver.download_url('2.53')).to match("2.53/IEDriverServer_Win32") }
  end
end
