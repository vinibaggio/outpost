require 'net/ping/external'

module Outpost
  module Scouts
    class Ping < Outpost::Scout
      extend Outpost::Expectations::ResponseTime
      attr_reader :response_time

      def setup(options)
        @host = options[:host]
      end

      def execute
        # FIXME Apply Dependency Injection Principle here
        pinger = Net::Ping::External.new
        if pinger.ping(@host)
          @response_time = pinger.duration
        end
      end
    end
  end
end
