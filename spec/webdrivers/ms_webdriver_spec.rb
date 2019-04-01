require 'spec_helper'

describe Webdrivers::MSWebdriver do
  let(:mswebdriver) { described_class }
  let(:update_failed_msg) { /^Update site is unreachable. Try downloading 'MicrosoftWebDriver(.exe)?' manually from (.*)?and place in '(.*)?\.webdrivers'$/ }

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
    before do
      allow(mswebdriver).to receive(:site_available?).and_return(false)
      mswebdriver.remove
    end

    it 'raises exception downloading' do
      expect { mswebdriver.download }.to raise_error(StandardError, update_failed_msg)
    end
  end
end
