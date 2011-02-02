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

      def execute
        # FIXME Apply Dependency Injection Principle here
        response = Net::HTTP.get_response(@host, @path, @port)
        @response_code = response.code.to_i
        @response_body = response.body
      end
    end
  end
end
