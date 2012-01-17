require 'net/http'
require 'outpost/expectations'

module Outpost
  module Scouts
    # Uses ruby's own Net:HTTP to send HTTP requests and evaluate response
    # body, response time and response code.
    #
    # * Responds to response_time expectation
    #   ({Outpost::Expectations::ResponseTime})
    # * Responds to response_code expectation
    #   ({Outpost::Expectations::ResponseCode})
    # * Responds to response_body expectation
    #   ({Outpost::Expectations::ResponseBody})
    #
    class Http < Outpost::Scout
      extend Outpost::Expectations::ResponseCode
      extend Outpost::Expectations::ResponseBody
      extend Outpost::Expectations::ResponseTime

      attr_reader :response_code, :response_body, :response_time
      report_data :response_code, :response_body, :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :host The host that will be connected to.
      # @option options [Number] :port The port that will be used to.
      # @option options [String] :path The path that will be fetched from the
      #   host.
      # @option options [String] :http_class The class that will be used to
      #   fetch the page, defaults to Net::HTTP
      def setup(options)
        @host       = options[:host]
        @port       = options[:port]       || 80
        @path       = options[:path]       || '/'
        @http_class = options[:http_class] || Net::HTTP
        @request_head = options.has_key?(:request_head) ? options[:request_head] : false
      end

      # Runs the scout, connecting to the host and getting the response code,
      # body and time.
      def execute
        previous_time = Time.now
        if @request_head
          response = @http_class.request_head(@host, @path, @port)
        else
          response = @http_class.get_response(@host, @path, @port)
        end

        @response_time = (Time.now - previous_time) * 1000 # Miliseconds
        @response_code = response.code.to_i
        @response_body = response.body
      rescue SocketError, Errno::ECONNREFUSED
        @response_code = @response_body = @response_time = nil
      end
    end
  end
end
