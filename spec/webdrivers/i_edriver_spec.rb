require 'spec_helper'

describe Webdrivers::IEdriver do
  let(:iedriver) { described_class }

  it 'finds latest version' do
    old_version = Gem::Version.new('3.12.0')
    future_version = Gem::Version.new('4.0')
    desired_version = iedriver.desired_version

    expect(desired_version).to be > old_version
    expect(desired_version).to be < future_version
  end

  it 'downloads iedriver' do
    iedriver.remove
    expect(File.exist?(iedriver.download)).to be true
  end

  it 'removes iedriver' do
    iedriver.remove
    expect(iedriver.current_version).to be_nil
  end

  context 'when offline' do
    before do
      iedriver.instance_variable_set('@latest_version', nil)
      allow(iedriver).to receive(:site_available?).and_return(false)
    end

    it 'raises exception finding latest version' do
      expect { iedriver.latest_version }.to raise_error(StandardError, 'Can not reach site')
    end

    it 'raises exception downloading' do
      expect { iedriver.download }.to raise_error(StandardError, 'Can not reach site')
    end
  end
end
