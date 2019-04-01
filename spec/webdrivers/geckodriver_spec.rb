require 'spec_helper'

describe Webdrivers::Geckodriver do
  let(:geckodriver) { described_class }
  let(:update_failed_msg) { /^Update site is unreachable. Try downloading 'geckodriver(.exe)?' manually from (.*)?and place in '(.*)?\.webdrivers'$/ }

  it 'raises exception if unable to get latest geckodriver and no geckodriver present' do
    geckodriver.remove
    allow(geckodriver).to receive(:desired_version).and_return(nil)
    expect { geckodriver.update }.to raise_exception StandardError, update_failed_msg
  end

  it 'uses found version of geckodriver if latest release unable to be found' do
    geckodriver.download
    allow(geckodriver).to receive(:desired_version).and_return(nil)
    expect(geckodriver.update).to match(%r{\.webdrivers/geckodriver})
  end

  it 'finds latest version' do
    old_version = Gem::Version.new('0.17')
    future_version = Gem::Version.new('0.30')
    desired_version = geckodriver.desired_version

    expect(desired_version).to be > old_version
    expect(desired_version).to be < future_version
  end

  it 'downloads latest version by default' do
    geckodriver.download
    expect(geckodriver.current_version).to eq geckodriver.desired_version
  end

  it 'does not download if desired version already exists' do
    geckodriver.remove
    geckodriver.version = '0.23.0'
    geckodriver.download
    geckodriver.reset_network_requests
    geckodriver.update
    expect(geckodriver.network_requests).to be(0)
  end

  it 'downloads specified version' do
    begin
      geckodriver.remove
      geckodriver.version = '0.17.0'
      geckodriver.download
      expect(geckodriver.current_version.version).to eq '0.17.0'
    ensure
      geckodriver.version = nil
    end
  end

  it 'uses existing version if update site is unreachable' do
    geckodriver.remove
    geckodriver.version = '0.23.0'
    geckodriver.download
    allow(geckodriver).to receive(:site_available?).and_return(false)
    geckodriver.update
    geckodriver.version = nil
    expect(geckodriver.latest_version.version).to eq '0.23.0'
  end

  it 'removes geckodriver' do
    geckodriver.remove
    expect(geckodriver.current_version).to be_nil
  end

  context 'when offline' do
    before do
      allow(geckodriver).to receive(:site_available?).and_return(false)
      geckodriver.remove
      geckodriver.version = nil
    end

    it 'raises exception finding latest version if no existing binary' do
      expect { geckodriver.desired_version }.to raise_error(StandardError, update_failed_msg)
    end

    it 'raises exception downloading' do
      expect { geckodriver.download }.to raise_error(StandardError, update_failed_msg)
    end
  end
end
