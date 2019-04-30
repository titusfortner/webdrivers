require 'spec_helper'

describe Webdrivers::Chromedriver do
  let(:chromedriver) { described_class }

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
    latest_ver = chromedriver.latest_version.version
    expect(cur_ver).to eq latest_ver
  end

  it 'downloads specified version by Float' do
    chromedriver.remove
    chromedriver.version = 2.29
    chromedriver.download
    expect(chromedriver.current_version.version).to include '2.29'
  end

  it 'downloads specified version by String' do
    chromedriver.remove
    chromedriver.version = '73.0.3683.68'
    chromedriver.download
    expect(chromedriver.current_version.version).to eq '73.0.3683.68'
  end

  it 'removes chromedriver' do
    chromedriver.remove
    expect(chromedriver.current_version).to be_nil
  end

  context 'when using a Chromium version < 70.0.3538' do
    it 'downloads chromedriver 2.46' do
      chromedriver.remove
      allow(chromedriver).to receive(:chrome_version).and_return('70.0.0')
      chromedriver.update

      expect(chromedriver.current_version.version[/\d+.\d+/]).to eq('2.46')
    end
  end

  # Workaround for Google Chrome when using Jruby on Windows.
  # @see https://github.com/titusfortner/webdrivers/issues/41
  if RUBY_PLATFORM == 'java' && Selenium::WebDriver::Platform.windows?
    context 'when using Jruby on Windows' do
      it 'uses Jruby specific workaround to retrieve the Google Chrome version' do
        chromedriver.remove
        chromedriver.update
        expect(chromedriver.current_version).not_to be_nil
      end
    end
  end

  context 'when offline' do
    before do
      chromedriver.instance_variable_set('@latest_version', nil)
      allow(chromedriver).to receive(:site_available?).and_return(false)
    end

    it 'raises exception finding latest version' do
      expect { chromedriver.latest_version }.to raise_error(StandardError, 'Can not reach site')
    end

    it 'raises exception downloading' do
      expect { chromedriver.download }.to raise_error(StandardError, 'Can not reach site')
    end
  end

  it 'allows setting of install directory' do
    begin
      install_dir = File.expand_path(File.join(ENV['HOME'], '.webdrivers2'))
      Webdrivers.install_dir = install_dir
      expect(chromedriver.install_dir).to eq install_dir
    ensure
      Webdrivers.install_dir = nil
    end
  end

  it 'returns full location of binary' do
    install_dir = File.expand_path(File.join(ENV['HOME'], '.webdrivers'))
    expect(chromedriver.binary).to match %r{#{install_dir}/chromedriver}
  end
end
