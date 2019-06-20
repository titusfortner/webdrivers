# frozen_string_literal: true

require 'spec_helper'

describe Webdrivers::ChromeFinder do
  let(:chrome_finder) { described_class }

  context 'when the user relies on the gem to figure out the location of Chrome' do
    it 'determines the location correctly based on the current OS' do
      expect(chrome_finder.location).not_to be_nil
    end
  end

  context 'when the user provides a path to the Chrome binary' do
    it 'uses Selenium::WebDriver::Chrome.path when it is defined' do
      Selenium::WebDriver::Chrome.path = chrome_finder.location
      allow(chrome_finder).to receive(:win_location)
      allow(chrome_finder).to receive(:mac_location)
      allow(chrome_finder).to receive(:linux_location)
      expect(chrome_finder.version).not_to be_nil
      expect(chrome_finder).not_to have_received(:win_location)
      expect(chrome_finder).not_to have_received(:mac_location)
      expect(chrome_finder).not_to have_received(:linux_location)
    end

    it "uses ENV['WD_CHROME_PATH'] when it is defined" do
      allow(ENV).to receive(:[]).with('WD_CHROME_PATH').and_return(chrome_finder.location)
      allow(chrome_finder).to receive(:win_location)
      allow(chrome_finder).to receive(:mac_location)
      allow(chrome_finder).to receive(:linux_location)
      expect(chrome_finder.version).not_to be_nil
      expect(chrome_finder).not_to have_received(:win_location)
      expect(chrome_finder).not_to have_received(:mac_location)
      expect(chrome_finder).not_to have_received(:linux_location)
    end

    it 'uses Selenium::WebDriver::Chrome.path over WD_CHROME_PATH' do
      Selenium::WebDriver::Chrome.path = chrome_finder.location
      allow(ENV).to receive(:[]).with('WD_CHROME_PATH').and_return('my_wd_chrome_path')
      expect(chrome_finder.version).not_to be_nil
      expect(ENV).not_to have_received(:[]).with('WD_CHROME_PATH')
    end
  end
end
