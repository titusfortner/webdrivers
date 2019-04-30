# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::MSWebdriver do
  let(:mswebdriver) { described_class }

  it 'downloads mswebdriver' do
    mswebdriver.remove
    allow(mswebdriver).to receive(:desired_version).and_return(mswebdriver.latest_version)
    expect(File.exist?(mswebdriver.download)).to be true
  end

  it 'removes mswebdriver' do
    mswebdriver.remove
    expect(File.exist?(mswebdriver.send(:binary))).to be false
  end

  context 'when offline' do
    before { allow(mswebdriver).to receive(:site_available?).and_return(false) }

    it 'raises exception downloading' do
      expect { mswebdriver.download }.to raise_error(StandardError, 'Can not reach site')
    end
  end
end
