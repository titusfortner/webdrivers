# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers do
  describe '#cache_time' do
    before { Webdrivers::Chromedriver.remove }

    after { described_class.cache_time = 0 }

    it 'does not warn if cache time is set' do
      described_class.cache_time = 50

      msg = /Webdrivers Driver caching is turned off in this version, but will be enabled by default in 4\.x/
      expect { Webdrivers::Chromedriver.update }.not_to output(msg).to_stdout_from_any_process
    end
  end
end
