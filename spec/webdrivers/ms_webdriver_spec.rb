# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::MSWebdriver do
  let(:mswebdriver) { described_class }

  before do
    allow(mswebdriver).to receive(:system_call).and_return('41.16299.248.0')
    mswebdriver.remove
    mswebdriver.required_version = nil
  end

  describe '#install_dir' do
    it 'uses ~/.webdrivers as default value' do
      expect(mswebdriver.install_dir).to include('.webdriver')
    end

    it 'raises ConnectionError if offline and no binary is found' do
      allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

      msg = %r{Can not reach https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/}
      expect { mswebdriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
    end
  end

  describe '#current_version' do
    it 'raises a NotImplementedError' do
      msg = 'Unable to programatically determine the version of most MicrosoftWebDriver.exe'
      expect { mswebdriver.current_version }.to raise_error(NotImplementedError, msg)
    end
  end

  describe '#latest_version' do
    it 'finds the latest version from parsed hash' do
      base = 'https://download.microsoft.com/download/'
      file_name = 'MicrosoftWebDriver.exe'

      hash = {Gem::Version.new('17134') => "#{base}F/8/A/F8AF50AB-3C3A-4BC4-8773-DC27B32988DD/#{file_name}",
              Gem::Version.new('16299') => "#{base}D/4/1/D417998A-58EE-4EFE-A7CC-39EF9E020768/#{file_name}",
              Gem::Version.new('15063') => "#{base}3/4/2/342316D7-EBE0-4F10-ABA2-AE8E0CDF36DD/#{file_name}"}
      allow(mswebdriver).to receive(:downloads).and_return(hash)

      expect(mswebdriver.latest_version).to eq Gem::Version.new('16299')
    end

    it 'raises a VersionError for Microsoft Edge version 18' do
      allow(mswebdriver).to receive(:windows_version).and_return(Gem::Version.new(45.0))

      expect { mswebdriver.latest_version }.to raise_error(Webdrivers::VersionError)
    end

    it 'correctly parses the downloads page' do
      expect(mswebdriver.send(:downloads)).not_to be_empty
    end
  end

  describe '#required_version' do
    it 'returns the version specified as a Float' do
      mswebdriver.required_version = 0.12

      expect(mswebdriver.required_version).to eq Gem::Version.new('0.12')
    end

    it 'returns the version specified as a String' do
      mswebdriver.required_version = '0.12.1'

      expect(mswebdriver.required_version).to eq Gem::Version.new('0.12.1')
    end
  end

  describe '#remove' do
    it 'removes existing mswebdriver' do
      mswebdriver.update

      mswebdriver.remove
      expect(File.exist?(mswebdriver.driver_path)).to eq false
    end

    it 'does not raise exception if no mswebdriver found' do
      mswebdriver.update

      expect { mswebdriver.remove }.not_to raise_error
    end
  end

  describe '#update' do
    it 'downloads binary from the list if it does not exist' do
      allow(mswebdriver).to receive(:downloads).and_return(mswebdriver.send(:downloads))
      mswebdriver.update

      expect(mswebdriver).to have_received(:downloads)
      expect(File.exist?(mswebdriver.driver_path)).to eq true
    end

    it 'does not download binary if one exists and offline' do
      allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
      allow(File).to receive(:exist?).with(mswebdriver.driver_path).and_return(true)
      allow(mswebdriver).to receive(:download_url)

      mswebdriver.update
      expect(mswebdriver).not_to have_received(:download_url)
    end

    it 'uses provided value' do
      begin
        install_dir = File.expand_path(File.join(ENV['HOME'], '.webdrivers2'))
        Webdrivers.install_dir = install_dir

        expect(mswebdriver.install_dir).to eq install_dir
      ensure
        Webdrivers.install_dir = nil
      end
    end
  end

  describe '#driver_path' do
    it 'returns full location of binary' do
      expect(mswebdriver.driver_path).to eq("#{File.join(ENV['HOME'])}/.webdrivers/MicrosoftWebDriver.exe")
    end
  end
end
