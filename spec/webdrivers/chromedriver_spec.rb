# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::Chromedriver do
  let(:chromedriver) { described_class }

  before do
    chromedriver.remove
    chromedriver.version = nil
  end

  describe '#update' do
    context 'when evaluating #correct_binary?' do
      it 'does not download when latest version and current version match' do
        allow(chromedriver).to receive(:latest_version).and_return(Gem::Version.new('72.0.0'))
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new('72.0.0'))

        chromedriver.update

        expect(chromedriver.send(:downloaded?)).to be false
      end

      it 'does not download when offline, binary exists and is less than v70' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(chromedriver).to receive(:downloaded?).and_return(true)
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new(69))

        chromedriver.update

        expect(File.exist?(chromedriver.binary)).to be false
      end

      it 'does not download when offline, binary exists and matches major browser version' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(chromedriver).to receive(:downloaded?).and_return(true)
        allow(chromedriver).to receive(:chrome_version).and_return(Gem::Version.new('73.0.3683.68'))
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new('73.0.3683.20'))

        chromedriver.update

        expect(File.exist?(chromedriver.binary)).to be false
      end

      it 'raises ConnectionError when offline, and binary does not match major browser version' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(chromedriver).to receive(:downloaded?).and_return(true)
        allow(chromedriver).to receive(:chrome_version).and_return(Gem::Version.new('73.0.3683.68'))
        allow(chromedriver).to receive(:current_version).and_return(Gem::Version.new('72.0.0.0'))

        msg = %r{Can not reach https://chromedriver.storage.googleapis.com}
        expect { chromedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end

      it 'raises ConnectionError when offline, and no binary exists' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)
        allow(chromedriver).to receive(:downloaded?).and_return(false)

        msg = %r{Can not reach https://chromedriver.storage.googleapis.com}
        expect { chromedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end

    context 'when correct binary is found' do
      before { allow(chromedriver).to receive(:correct_binary?).and_return(true) }

      it 'does not download' do
        chromedriver.update

        expect(chromedriver.current_version).to be_nil
      end

      it 'does not raise exception if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        chromedriver.update

        expect(chromedriver.current_version).to be_nil
      end
    end

    context 'when correct binary is not found' do
      before { allow(chromedriver).to receive(:correct_binary?).and_return(false) }

      it 'downloads binary' do
        chromedriver.update

        expect(chromedriver.current_version).not_to be_nil
      end

      it 'raises ConnectionError if offline' do
        allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

        msg = %r{Can not reach https://chromedriver.storage.googleapis.com/}
        expect { chromedriver.update }.to raise_error(Webdrivers::ConnectionError, msg)
      end
    end
  end

  describe '#current_version' do
    it 'returns nil if binary does not exist on the system' do
      allow(chromedriver).to receive(:binary).and_return('')

      expect(chromedriver.current_version).to be_nil
    end

    it 'returns a Gem::Version instance if binary is on the system' do
      allow(chromedriver).to receive(:downloaded?).and_return(true)
      allow(chromedriver).to receive(:system_call).and_return '71.0.3578.137'

      expect(chromedriver.current_version).to eq Gem::Version.new('71.0.3578.137')
    end
  end

  describe '#latest_version' do
    it 'returns 2.41 if the browser version is less than 70' do
      allow(chromedriver).to receive(:chrome_version).and_return('69.0.0')

      expect(chromedriver.latest_version).to eq(Gem::Version.new('2.41'))
    end

    it 'returns the correct point release for a production version greater than 70' do
      allow(chromedriver).to receive(:chrome_version).and_return '71.0.3578.9999'

      expect(chromedriver.latest_version).to eq Gem::Version.new('71.0.3578.137')
    end

    it 'raises VersionError for beta version' do
      allow(chromedriver).to receive(:chrome_version).and_return('100.0.0')
      msg = 'you appear to be using a non-production version of Chrome; please set '\
'`Webdrivers::Chromedriver.version = <desired driver version>` to an known chromedriver version: '\
'https://chromedriver.storage.googleapis.com/index.html'

      expect { chromedriver.latest_version }.to raise_exception(Webdrivers::VersionError, msg)
    end

    it 'raises VersionError for unknown version' do
      allow(chromedriver).to receive(:chrome_version).and_return('72.0.9999.0000')
      msg = 'please set `Webdrivers::Chromedriver.version = <desired driver version>` to an known chromedriver '\
'version: https://chromedriver.storage.googleapis.com/index.html'

      expect { chromedriver.latest_version }.to raise_exception(Webdrivers::VersionError, msg)
    end

    it 'raises ConnectionError when offline' do
      allow(Net::HTTP).to receive(:get_response).and_raise(SocketError)

      msg = %r{^Can not reach https://chromedriver.storage.googleapis.com}
      expect { chromedriver.latest_version }.to raise_error(Webdrivers::ConnectionError, msg)
    end
  end

  describe '#desired_version' do
    it 'returns #latest_version if version is not specified' do
      allow(chromedriver).to receive(:latest_version)

      chromedriver.desired_version
      expect(chromedriver).to have_received(:latest_version)
    end

    it 'returns the version specified as a Float' do
      chromedriver.version = 73.0

      expect(chromedriver.desired_version).to eq Gem::Version.new('73.0')
    end

    it 'returns the version specified as a String' do
      chromedriver.version = '73.0'

      expect(chromedriver.desired_version).to eq Gem::Version.new('73.0')
    end
  end

  describe '#remove' do
    it 'removes existing chromedriver' do
      chromedriver.update

      chromedriver.remove
      expect(chromedriver.current_version).to be_nil
    end

    it 'does not raise exception if no chromedriver found' do
      chromedriver.update

      expect { chromedriver.remove }.not_to raise_error
    end
  end

  describe '#install_dir' do
    it 'uses ~/.webdrivers as default value' do
      expect(chromedriver.install_dir).to include('.webdriver')
    end

    it 'uses provided value' do
      begin
        install_dir = File.expand_path(File.join(ENV['HOME'], '.webdrivers2'))
        Webdrivers.install_dir = install_dir

        expect(chromedriver.install_dir).to eq install_dir
      ensure
        Webdrivers.install_dir = nil
      end
    end
  end

  describe '#binary' do
    it 'returns full location of binary' do
      expect(chromedriver.binary).to match("#{File.join(ENV['HOME'])}/.webdrivers/chromedriver")
    end
  end
end
