require "spec_helper"

describe Webdrivers::Geckodriver do

  let(:geckodriver) { Webdrivers::Geckodriver }

  it 'finds latest version' do
    expect(geckodriver.latest).to be > 0.17
    expect(geckodriver.latest).to be < 0.2
  end

  it 'downloads latest version by default' do
    geckodriver.download
    expect(geckodriver.current).to eq geckodriver.latest
  end

  it 'downloads specified version' do
    geckodriver.remove
    geckodriver.download(0.17)
    expect(geckodriver.current).to eq 0.17
  end

  it 'removes geckodriver' do
    geckodriver.remove
    expect(geckodriver.current).to be_nil
  end

  context 'when offline' do
    before { allow(geckodriver).to receive(:site_available?).and_return(false) }

    it 'raises exception finding latest version' do
      expect {geckodriver.latest}.to raise_error(StandardError, "Can not reach site")
    end

    it 'raises exception downloading' do
      expect {geckodriver.download}.to raise_error(StandardError, "Can not reach site")
    end
  end

end
