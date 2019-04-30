# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::Geckodriver do
  let(:geckodriver) { described_class }

  it 'raises exception if unable to get latest geckodriver and no geckodriver present' do
    geckodriver.remove
    allow(geckodriver).to receive(:desired_version).and_return(nil)
    gd = 'Unable to find the latest version of geckodriver'
    msg = /^#{gd}(.exe)?; try downloading manually from (.*)?and place in (.*)?\.webdrivers$/
    expect { geckodriver.update }.to raise_exception StandardError, msg
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

  it 'removes geckodriver' do
    geckodriver.remove
    expect(geckodriver.current_version).to be_nil
  end

  context 'when offline' do
    before do
      geckodriver.instance_variable_set('@latest_version', nil)
      allow(geckodriver).to receive(:site_available?).and_return(false)
    end

    it 'raises exception finding latest version' do
      expect { geckodriver.desired_version }.to raise_error(StandardError, 'Can not reach site')
    end

    it 'raises exception downloading' do
      expect { geckodriver.download }.to raise_error(StandardError, 'Can not reach site')
    end
  end
end
