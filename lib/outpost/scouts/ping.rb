require 'net/ping/external'
require 'outpost/expectations'

module Outpost
  module Scouts
    class Ping < Outpost::Scout
      extend Outpost::Expectations::ResponseTime
      attr_reader :response_time

      def setup(options)
        @host = options[:host]
      end

      def execute(pinger=Net::Ping::External.new)
        if pinger.ping(@host)
          # Miliseconds
          @response_time = pinger.duration * 1000
        end
      end
    end
  end
end
