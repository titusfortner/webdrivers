# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::MSWebdriver do
  let(:mswebdriver) { described_class }

  it 'gives deprecation for using it' do
    msg = /WARN Webdrivers Microsoft WebDriver for the Edge browser is no longer supported by Webdrivers gem/

    if defined?(Selenium::WebDriver::VERSION) && Selenium::WebDriver::VERSION > '3.141.0'
      expect { Selenium::WebDriver::Edge::Service.driver_path }.to output(msg).to_stdout_from_any_process
    else
      expect { Selenium::WebDriver::Edge.driver_path }.to output(msg).to_stdout_from_any_process
    end
  end

  it 'does not give deprecation when set to ignore' do
    described_class.ignore = true

    service = instance_double(Selenium::WebDriver::Service, host: '', start: nil, uri: '')
    bridge = instance_double(Selenium::WebDriver::Remote::Bridge, create_session: nil, session_id: '')

    allow(Selenium::WebDriver::Service).to receive(:new).and_return(service)
    allow(Selenium::WebDriver::Remote::Bridge).to receive(:new).and_return(bridge)
    allow(Selenium::WebDriver::Remote::W3C::Bridge).to receive(:new)

    expect { Selenium::WebDriver.for :edge }.not_to output.to_stdout_from_any_process
  end
end
