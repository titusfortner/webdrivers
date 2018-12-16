require "net_http_ssl_fix"
require "webdrivers/selenium"
require "webdrivers/logger"
require "webdrivers/common"
require "webdrivers/chromedriver"
require "webdrivers/geckodriver"
require "webdrivers/iedriver"
require "webdrivers/mswebdriver"

module Webdrivers

  class << self

    attr_accessor :proxy_addr, :proxy_port, :proxy_user, :proxy_pass, :install_dir

    def logger
      @logger ||= Webdrivers::Logger.new
    end

    def configure
      yield self
    end
  end
end
