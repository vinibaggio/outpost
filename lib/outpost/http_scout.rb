require 'net/http'
require 'outpost'

require 'outpost/response_code_expectation'
require 'outpost/response_body_expectation'

module Outpost
  class HttpScout < Outpost::Scout
    extend Outpost::ResponseCodeExpectation
    extend Outpost::ResponseBodyExpectation

    attr_reader :response_code, :response_body

    def setup(options)
      @host = options[:host]
      @port = options[:port] || 80
      @path = options[:path] || '/'
    end

    def execute
      response = Net::HTTP.get_response(@host, @path, @port)
      @response_code = response.code.to_i
      @response_body = response.body
    end
  end
end
