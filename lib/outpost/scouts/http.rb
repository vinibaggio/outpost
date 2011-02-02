require 'net/http'
require 'outpost/expectations'

module Outpost
  module Scouts
    class Http < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody

      attr_reader :response_code, :response_body

      def setup(options)
        @host = options[:host]
        @port = options[:port] || 80
        @path = options[:path] || '/'
      end

      def execute(http_class=Net::HTTP)
        response = http_class.get_response(@host, @path, @port)

        @response_code = response.code.to_i
        @response_body = response.body
      rescue SocketError, Errno::ECONNREFUSED
        @response_code = @response_body = nil
      end
    end
  end
end
