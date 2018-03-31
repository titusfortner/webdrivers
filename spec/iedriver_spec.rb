require "spec_helper"

describe Webdrivers::IEdriver do

  let(:iedriver) { Webdrivers::IEdriver }

  it 'finds latest version' do
    major, minor = iedriver.latest.to_s.split('.').map(&:to_i)
    expect(major).to eq 3
    expect(minor).to be > 10
    expect(iedriver.latest).to be < 4
  end

  it 'downloads iedriver' do
    iedriver.remove
    expect(File.exist?(iedriver.download)).to be true
  end

  it 'removes iedriver' do
    iedriver.remove
    expect(iedriver.current).to be_nil
  end

  context 'when offline' do
    before { allow(iedriver).to receive(:site_available?).and_return(false) }

    it 'raises exception finding latest version' do
      expect {iedriver.latest}.to raise_error(StandardError, "Can not reach site")
    end

    it 'raises exception downloading' do
      expect {iedriver.download}.to raise_error(StandardError, "Can not reach site")
    end
  end

end
