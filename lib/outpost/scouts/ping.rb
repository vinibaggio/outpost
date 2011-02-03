begin
  require 'net/ping/external'
rescue LoadError => e
  puts "Please install net-ping gem: gem install net-ping".
  raise
end

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
