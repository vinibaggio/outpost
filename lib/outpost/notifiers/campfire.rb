begin
  require 'tinder'
rescue LoadError => e
  puts "Please install tinder gem: gem install tinder"
  raise
end

module Outpost
  module Notifiers
    # The Campfire notifier issues Outpost notifications to the 37signals'
    # Campfire web app (http://campfirenow.com). It issues messages about
    # the system status in the specified subdomain and room.
    #
    # This requires the 'tinder' gem to be installed.
    class Campfire

      # @param [Hash] Options to create a campfire notification.
      # @option options [String] :subdomain The subdomain of your campfire
      #   rooms
      # @option options [String] :token An access token, can be found
      #   in your Account info
      # @option options [String] :room The room notifications will be sent to
      # @option options [Class] :campfire_notifier Another Campfire
      #   notification class. Defaults to Tinder's gem
      def initialize(options={})
        @subdomain         = options[:subdomain]         || ''
        @token             = options[:token]             || ''
        @room              = options[:room]              || ''
        @campfire_notifier = options[:campfire_notifier] || Tinder::Campfire

        if [@subdomain, @token, @room].any?(&:empty?)
          raise ArgumentError, 'You need to supply :token, :subdomain and :room.'
        end
      end

      # Issues a notification to a Campfire room. This is a callback, called by
      # an Outpost instance.
      # @param [Outpost::Application, #read] outpost an instance of an outpost, containing
      #   latest status, messages and reports that can be queried to build
      #   a notification message.
      def notify(outpost)
        campfire = @campfire_notifier.new @subdomain, :token => @token
        room     = campfire.find_room_by_name @room

        status = outpost.last_status.to_s
        room.speak "System is #{status}: #{outpost.messages.join(',')}"
      end
    end
  end
end
