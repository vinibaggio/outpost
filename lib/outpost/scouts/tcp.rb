require 'net/ping/tcp'
require 'outpost/expectations'

module Outpost
  module Scouts
    # Uses net/ping tcp pinger to check if port is open
    #
    # * Responds to response_time expectation
    #   ({Outpost::Expectations::ResponseTime})
    class Tcp < Ping
      extend Outpost::Expectations::ResponseTime
      attr_reader :response_time
      report_data :response_time

      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :host The host that will be "pinged".
      # @option options [Object] :pinger An object that can ping hosts.
      #   Defaults to Net::Ping::Tcp.new
      def setup(options)
        host   = options[:host]
        port   = options[:port]
        pinger = options[:pinger] || Net::Ping::TCP

        @pinger = pinger.new(host, port)
      end

      # Runs the scout, pinging the host and getting the duration.
      def execute
        if @pinger.ping?
          # Miliseconds
          @response_time = @pinger.duration * 1000
        end
      end
    end
  end
end
