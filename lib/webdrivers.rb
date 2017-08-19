require "webdrivers/selenium"
require "webdrivers/logger"
require "webdrivers/common"
require "webdrivers/chromedriver"
require "webdrivers/geckodriver"
require "webdrivers/iedriver"
require "webdrivers/mswebdriver"

module Webdrivers
  def self.logger
    @logger ||= Webdrivers::Logger.new
  end
end
