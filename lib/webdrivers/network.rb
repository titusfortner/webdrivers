# frozen_string_literal: true

module Webdrivers
  class Network
    class << self
      def get(url, limit = 10)
        Webdrivers.logger.debug "Getting URL: #{url}"

        raise ConnectionError, 'Too many HTTP redirects' if limit.zero?

        begin
          response = http.get_response(URI(url))
        rescue SocketError
          raise ConnectionError, "Can not reach #{url}"
        end

        Webdrivers.logger.debug "Get response: #{response.inspect}"

        case response
        when Net::HTTPSuccess
          response.body
        when Net::HTTPRedirection
          location = response['location']
          Webdrivers.logger.debug "Redirected to URL: #{location}"
          get(location, limit - 1)
        else
          response.value
        end
      end

      def http
        if using_proxy
          Net::HTTP.Proxy(Webdrivers.proxy_addr, Webdrivers.proxy_port,
                          Webdrivers.proxy_user, Webdrivers.proxy_pass)
        else
          Net::HTTP
        end
      end

      def using_proxy
        Webdrivers.proxy_addr && Webdrivers.proxy_port
      end
    end
  end
end
