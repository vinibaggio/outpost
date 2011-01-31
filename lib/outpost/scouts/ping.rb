require 'net/ping'

module Outpost
  module Scouts
    class Ping < Outpost::Scout
      attr_reader :response_time

      def setup(options)
        @host = options[:host]
      end

      def execute
        # FIXME Apply Dependency Injection Principle here
        pinger = Net::Ping::External.new
        if pinger.ping
          @response_time = external.duration
        end
      end
    end
  end
end
