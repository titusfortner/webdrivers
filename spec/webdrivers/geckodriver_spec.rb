# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::Geckodriver do
  let(:geckodriver) { described_class }

  before do
    geckodriver.remove
    geckodriver.required_version = nil
  end

  describe '#update' do
    context 'when evaluating #correct_binary?' do
      it 'does not download when latest version and current version match' do
        allow(geckodriver).to receive(:latest_version).and_return(Gem::Version.new('0.3.0'))
        allow(geckodriver).to receive(:current_version).and_return(Gem::Version.new('0.3.0'))

        geckodriver.update

        expect(geckodriver.send(:downloaded?)).to be false
      end

      it 'does not download when offline, but binary exists' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(geckodriver).to receive(:downloaded?).and_return(true)

        geckodriver.update

        expect(File.exist?(geckodriver.driver_path)).to be false
      end

      it 'raises ConnectionError when offline, and no binary exists' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(geckodriver).to receive(:downloaded?).and_return(false)

        expect { geckodriver.update }.to raise_error(Webdrivers::ConnectionError)
      end
    end

    context 'when correct binary is found' do
      before { allow(geckodriver).to receive(:correct_binary?).and_return(true) }

      it 'does not download' do
        geckodriver.update

        expect(geckodriver.current_version).to be_nil
      end

      it 'does not raise exception if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        geckodriver.update

        expect(geckodriver.current_version).to be_nil
      end
    end

    context 'when correct binary is not found' do
      before { allow(geckodriver).to receive(:correct_binary?).and_return(false) }

      it 'downloads binary' do
        geckodriver.update

        expect(geckodriver.current_version).not_to be_nil
      end

      it 'raises ConnectionError if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        msg = %r{Can not reach https://github.com/mozilla/geckodriver/releases}
        expect { geckodriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end
  end

  describe '#current_version' do
    it 'returns nil if binary does not exist on the system' do
      allow(geckodriver).to receive(:driver_path).and_return('')

      expect(geckodriver.current_version).to be_nil
    end

    it 'returns a Gem::Version instance if binary is on the system' do
      allow(geckodriver).to receive(:downloaded?).and_return(true)

      return_value = "geckodriver 0.24.0 ( 2019-01-28)

The source code of this program is available from
testing/geckodriver in https://hg.mozilla.org/mozilla-central.

This program is subject to the terms of the Mozilla Public License 2.0.
You can obtain a copy of the license at https://mozilla.org/MPL/2.0/"

      allow(Webdrivers::System).to receive(:call).with("#{geckodriver.driver_path} --version").and_return return_value

      expect(geckodriver.current_version).to eq Gem::Version.new('0.24.0')
    end
  end

  describe '#latest_version' do
    it 'finds the latest version from parsed hash' do
      base = 'https://github.com/mozilla/geckodriver/releases/download'
      hash = {Gem::Version.new('0.1.0') => "#{base}/v0.1.0/geckodriver-v0.1.0-macos.tar.gz",
              Gem::Version.new('0.2.0') => "#{base}/v0.2.0/geckodriver-v0.2.0-macos.tar.gz",
              Gem::Version.new('0.3.0') => "#{base}/v0.3.0/geckodriver-v0.3.0-macos.tar.gz"}
      allow(geckodriver).to receive(:downloads).and_return(hash)

      expect(geckodriver.latest_version).to eq Gem::Version.new('0.3.0')
    end

    it 'correctly parses the downloads page' do
      expect(geckodriver.send(:downloads)).not_to be_empty
    end
  end

  describe '#required_version=' do
    it 'returns the version specified as a Float' do
      geckodriver.required_version = 0.12

      expect(geckodriver.required_version).to eq Gem::Version.new('0.12')
    end

    it 'returns the version specified as a String' do
      geckodriver.required_version = '0.12.1'

      expect(geckodriver.required_version).to eq Gem::Version.new('0.12.1')
    end
  end

  describe '#remove' do
    it 'removes existing geckodriver' do
      geckodriver.update

      geckodriver.remove
      expect(geckodriver.current_version).to be_nil
    end

    it 'does not raise exception if no geckodriver found' do
      geckodriver.update

      expect { geckodriver.remove }.not_to raise_error
    end
  end

  describe '#install_dir' do
    it 'uses ~/.webdrivers as default value' do
      expect(Webdrivers::System.install_dir).to include('.webdriver')
    end

    it 'uses provided value' do
      begin
        install_dir = File.expand_path(File.join(ENV['HOME'], '.webdrivers2'))
        Webdrivers.install_dir = install_dir

        expect(Webdrivers::System.install_dir).to eq install_dir
      ensure
        Webdrivers.install_dir = nil
      end
    end
  end

  describe '#driver_path' do
    it 'returns full location of binary' do
      expect(geckodriver.driver_path).to match("#{File.join(ENV['HOME'])}/.webdrivers/geckodriver")
    end
  end
end
