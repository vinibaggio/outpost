require 'net/http'
require 'outpost'

module Outpost
  class HttpScout < Outpost::Scout
    register_hook :response_code, lambda { |scout,response_code|
      scout.response_code == response_code.to_i
    }
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
