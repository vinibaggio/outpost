begin
  require 'net/ping/external'
rescue LoadError => e
  puts "Please install net-ping gem: gem install net-ping".
  raise
end

require 'outpost/expectations'

module Outpost
  module Scouts
    # Uses system's "ping" command line tool to check if the server is
    # responding in a timely manner.
    #
    # * Responds to response_time expectation
    #   ({Outpost::Expectations::ResponseTime})
    #
    # It needs the 'net-ping' gem.
    class Ping < Outpost::Scout
      extend Outpost::Expectations::ResponseTime
      attr_reader :response_time


      # Configure the scout with given options.
      # @param [Hash] Options to setup the scout
      # @option options [String] :host The host that will be "pinged".
      # @option options [Object] :pinger An object that can ping hosts.
      #   Defaults to Net::Ping::External.new
      def setup(options)
        @host   = options[:host]
        @pinger = options[:pinger] || Net::Ping::External.new
      end

      # Runs the scout, pinging the host and getting the duration.
      def execute
        if @pinger.ping(@host)
          # Miliseconds
          @response_time = @pinger.duration * 1000
        end
      end
    end
  end
end
