# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers do
  describe '#cache_time' do
    before { Webdrivers::Chromedriver.remove }

    after { described_class.cache_time = nil }

    context 'when cache time is not set' do
      before { described_class.cache_time = nil }

      it 'defaults cache time to 86,400 Seconds (24 hours)' do
        expect(described_class.cache_time).to eq(86_400)
      end
    end

    context 'when Webdrivers.cache_time is set' do
      before { described_class.cache_time = '999' }

      it 'returns user defined cache time' do
        expect(described_class.cache_time).to eq(999)
      end

      it 'returns cache time as an Integer' do
        expect(described_class.cache_time).to be_an_instance_of(Integer)
      end
    end

    context 'when ENV variable WD_CACHE_TIME is set' do
      before { described_class.cache_time = 86_400 }

      it 'uses cache time value from ENV variable over the Webdrivers.cache_time value' do
        allow(ENV).to receive(:[]).with('WD_CACHE_TIME').and_return(999)
        expect(described_class.cache_time).to be(999)
      end

      it 'returns cache time as an Integer' do
        allow(ENV).to receive(:fetch).with('WD_CACHE_TIME', 86_400).and_return('999')
        expect(described_class.cache_time).to be_an_instance_of(Integer)
      end
    end
  end

  describe '#install_dir' do
    it 'uses ~/.webdrivers as default value' do
      expect(described_class.install_dir).to include('.webdriver')
    end

    it 'uses provided value' do
      begin
        install_dir                 = File.expand_path(File.join(ENV['HOME'], '.webdrivers2'))
        described_class.install_dir = install_dir

        expect(described_class.install_dir).to eq install_dir
      ensure
        described_class.install_dir = nil
      end
    end

    context 'when ENV variable WD_INSTALL_DIR is set and Webdrivers.install_dir is not' do
      it 'uses path from the ENV variable' do
        begin
          described_class.install_dir = nil
          allow(ENV).to receive(:[]).with('WD_INSTALL_DIR').and_return('custom_dir')
          expect(described_class.install_dir).to be('custom_dir')
        ensure
          described_class.install_dir = nil
        end
      end
    end
  end
end
