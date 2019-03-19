require "spec_helper"

describe Webdrivers::Chromedriver do

  let(:chromedriver) { Webdrivers::Chromedriver }

  it 'updates' do
    chromedriver.update
  end

  it 'parses chromedriver versions before 2.10' do
    expect(chromedriver.send(:normalize, '2.9').version).to eq '2.9'
  end

  it 'finds latest version' do
    old_version = Gem::Version.new('2.30')
    future_version = Gem::Version.new('80.00')
    latest_version = chromedriver.latest_version

    expect(latest_version).to be > old_version
    expect(latest_version).to be < future_version
  end

  it 'downloads latest release for current version of Chrome by default' do
    chromedriver.remove
    chromedriver.download
    cur_ver    = chromedriver.current_version.version
    latest_ver = chromedriver.latest_version.version[0..3] # "72.0.3626.69" - > "72.0"
    expect(cur_ver).to eq latest_ver
  end

  it 'downloads specified version by Float' do
    chromedriver.remove
    chromedriver.version = 2.29
    chromedriver.download
    expect(chromedriver.current_version.version).to eq '2.29'
  end

  it 'downloads specified version by String' do
    chromedriver.remove
    chromedriver.version = '74.0.3729.6'
    chromedriver.download
    expect(chromedriver.current_version.version).to eq '74.0'
  end

  it 'removes chromedriver' do
    chromedriver.remove
    expect(chromedriver.current_version).to be_nil
  end

  context 'when offline' do
    before { allow(chromedriver).to receive(:site_available?).and_return(false) }

    it 'raises exception finding latest version' do
      expect {chromedriver.latest_version}.to raise_error(StandardError, "Can not reach site")
    end

    it 'raises exception downloading' do
      expect {chromedriver.download}.to raise_error(StandardError, "Can not reach site")
    end
  end

  it 'allows setting of install directory' do
    begin
      install_dir = File.expand_path(File.join(ENV['HOME'], ".webdrivers2"))
      Webdrivers.install_dir = install_dir
      expect(chromedriver.install_dir).to eq install_dir
    ensure
      Webdrivers.install_dir = nil
    end
  end

  it 'returns full location of binary' do
    install_dir = File.expand_path(File.join(ENV['HOME'], ".webdrivers"))
    expect(chromedriver.binary).to match /#{install_dir}\/chromedriver/
  end
end
