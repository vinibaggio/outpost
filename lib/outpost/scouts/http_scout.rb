require 'net/http'
require 'outpost'

module Outpost
  class HttpScout < Outpost::Scout
    attr_reader :response_code

    def setup(options)
      @host = options[:host]
      @port = options[:port] || 80
      @path = options[:path] || '/'
    end

    def execute
      @response_code = Net::HTTP.get_response(@host, @path, @port).code.to_i
    end
  end
end
