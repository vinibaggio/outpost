begin
  require 'tinder'
rescue LoadError => e
  puts "Please install tinder gem: gem install tinder"
  raise
end

module Outpost
  module Notifiers
    class Campfire
      def initialize(options={})
        @subdomain = options[:subdomain] || ''
        @token     = options[:token]     || ''
        @room      = options[:room]      || ''

        if [@subdomain, @token, @room].any?(&:empty?)
          raise ArgumentError, 'You need to supply :token, :subdomain and :room.'
        end
      end

      def notify(outpost, campfire_class=Tinder::Campfire)
        campfire = campfire_class.new @subdomain, :token => @token
        room     = campfire.find_room_by_name @room

        status = outpost.last_status.to_s
        room.speak "System is #{status}: #{outpost.messages.join(',')}"
      end
    end
  end
end
