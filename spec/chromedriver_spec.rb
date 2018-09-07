require "spec_helper"

describe Webdrivers::Chromedriver do

  let(:chromedriver) { Webdrivers::Chromedriver }

  it 'parses chromedriver versions before 2.10' do
    expect(chromedriver.send :normalize, '2.9').to eq 2.09
  end

  it 'finds latest version' do
    expect(chromedriver.latest).to be > 2.30
    expect(chromedriver.latest).to be < 2.9
  end

  it 'downloads latest version by default' do
    chromedriver.remove
    chromedriver.download
    expect(chromedriver.current).to eq chromedriver.latest
  end

  it 'downloads specified version' do
    chromedriver.remove
    chromedriver.download(2.29)
    expect(chromedriver.current).to eq 2.29
  end

  it 'removes chromedriver' do
    chromedriver.remove
    expect(chromedriver.current).to be_nil
  end

  context 'when offline' do
    before { allow(chromedriver).to receive(:site_available?).and_return(false) }

    it 'raises exception finding latest version' do
      expect {chromedriver.latest}.to raise_error(StandardError, "Can not download from website")
    end

    it 'raises exception downloading' do
      expect {chromedriver.download}.to raise_error(StandardError, "Can not download from website")
    end
  end

  it 'returns full location of binary' do
    install_dir = File.expand_path(File.join(ENV['HOME'], ".webdrivers"))
    expect(chromedriver.binary).to match /#{install_dir}\/chromedriver/
  end
end
