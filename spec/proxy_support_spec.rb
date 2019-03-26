require 'spec_helper'

class FakeDriver < Webdrivers::Common
  def self.http_object
    http
  end
end

describe 'Support for proxies' do
  let(:http_object) { FakeDriver.http_object }

  before do
    Webdrivers.proxy_addr = nil
    Webdrivers.proxy_port = nil
    Webdrivers.proxy_user = nil
    Webdrivers.proxy_pass = nil
  end

  it 'should allow the proxy values to be set via configuration' do
    Webdrivers.configure do |config|
      config.proxy_addr = 'proxy_addr'
      config.proxy_port = '8888'
      config.proxy_user = 'proxy_user'
      config.proxy_pass = 'proxy_pass'
    end

    expect(Webdrivers.proxy_addr).to eql 'proxy_addr'
    expect(Webdrivers.proxy_port).to eql '8888'
    expect(Webdrivers.proxy_user).to eql 'proxy_user'
    expect(Webdrivers.proxy_pass).to eql 'proxy_pass'
  end

  it 'should use the Proxy when the proxy_addr is set' do
    Webdrivers.configure do |config|
      config.proxy_addr = 'proxy_addr'
      config.proxy_port = '8080'
    end

    expect(http_object.instance_variable_get('@is_proxy_class')).to be true
  end

  it 'should not use the Proxy when proxy is not configured' do
    expect(http_object.instance_variable_get('@is_proxy_class')).to be false
  end
end
