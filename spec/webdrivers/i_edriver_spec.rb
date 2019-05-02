# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::IEdriver do
  let(:iedriver) { described_class }

  before do
    iedriver.remove
    iedriver.version = nil
  end

  describe '#update' do
    context 'when evaluating #correct_binary?' do
      it 'does not download when latest version and current version match' do
        allow(iedriver).to receive(:latest_version).and_return(Gem::Version.new('0.3.0'))
        allow(iedriver).to receive(:current_version).and_return(Gem::Version.new('0.3.0'))

        iedriver.update

        expect(iedriver.send(:exists?)).to be false
      end

      it 'does not download when offline, but binary exists' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(iedriver).to receive(:exists?).and_return(true)

        iedriver.update

        expect(File.exist?(iedriver.binary)).to be false
      end

      it 'raises ConnectionError when offline, and no binary exists' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(iedriver).to receive(:exists?).and_return(false)

        expect { iedriver.update }.to raise_error(Webdrivers::ConnectionError)
      end
    end

    context 'when correct binary is found' do
      before { allow(iedriver).to receive(:correct_binary?).and_return(true) }

      it 'does not download' do
        iedriver.update

        expect(iedriver.current_version).to be_nil
      end

      it 'does not raise exception if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        iedriver.update

        expect(iedriver.current_version).to be_nil
      end
    end

    context 'when correct binary is not found' do
      before { allow(iedriver).to receive(:correct_binary?).and_return(false) }

      it 'downloads binary' do
        iedriver.update

        expect(File.exist?(iedriver.binary)).to eq true
      end

      it 'raises ConnectionError if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        msg = %r{Can not reach https://selenium-release.storage.googleapis.com/}
        expect { iedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end
  end

  describe '#current_version' do
    it 'returns nil if binary does not exist on the system' do
      allow(iedriver).to receive(:binary).and_return('')

      expect(iedriver.current_version).to be_nil
    end

    it 'returns a Gem::Version instance if binary is on the system' do
      allow(iedriver).to receive(:exists?).and_return(true)

      return_value = 'something IEDriverServer.exe 3.5.1 something else'

      allow(iedriver).to receive(:system_call).and_return return_value

      expect(iedriver.current_version).to eq Gem::Version.new('3.5.1')
    end
  end

  describe '#latest_version' do
    it 'finds the latest version from parsed hash' do
      base = 'https://selenium-release.storage.googleapis.com/'
      hash = {Gem::Version.new('3.4.0') => "#{base}/3.4/IEDriverServer_Win32_3.4.0.zip",
              Gem::Version.new('3.5.0') => "#{base}/3.5/IEDriverServer_Win32_3.5.0.zip",
              Gem::Version.new('3.5.1') => "#{base}/3.5/IEDriverServer_Win32_3.5.1.zip"}
      allow(iedriver).to receive(:downloads).and_return(hash)

      expect(iedriver.latest_version).to eq Gem::Version.new('3.5.1')
    end

    it 'correctly parses the downloads page' do
      expect(iedriver.send(:downloads)).not_to be_empty
    end
  end

  describe '#desired_version' do
    it 'returns #latest_version if version is not specified' do
      allow(iedriver).to receive(:latest_version)
      iedriver.desired_version

      expect(iedriver).to have_received(:latest_version)
    end

    it 'returns the version specified as a Float' do
      iedriver.version = 0.12

      expect(iedriver.desired_version).to eq Gem::Version.new('0.12')
    end

    it 'returns the version specified as a String' do
      iedriver.version = '0.12.1'

      expect(iedriver.desired_version).to eq Gem::Version.new('0.12.1')
    end
  end

  describe '#remove' do
    it 'removes existing iedriver' do
      iedriver.update

      iedriver.remove
      expect(iedriver.current_version).to be_nil
    end

    it 'does not raise exception if no iedriver found' do
      iedriver.update

      expect { iedriver.remove }.not_to raise_error
    end
  end

  describe '#install_dir' do
    it 'uses ~/.webdrivers as default value' do
      expect(iedriver.install_dir).to include('.webdriver')
    end

    it 'uses provided value' do
      begin
        install_dir = File.expand_path(File.join(ENV['HOME'], '.webdrivers2'))
        Webdrivers.install_dir = install_dir

        expect(iedriver.install_dir).to eq install_dir
      ensure
        Webdrivers.install_dir = nil
      end
    end
  end

  describe '#binary' do
    it 'returns full location of binary' do
      expect(iedriver.binary).to eq("#{File.join(ENV['HOME'])}/.webdrivers/IEDriverServer.exe")
    end
  end
end
