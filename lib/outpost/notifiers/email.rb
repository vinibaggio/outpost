begin
  require 'mail'
rescue LoadError => e
  puts "Please install mail gem: gem install mail"
  raise
end

module Outpost
  module Notifiers
    class Email
      def initialize(options={})
        @from    = options[:from]
        @to      = options[:to]
        @subject = options[:subject] || 'Outpost notification'

        unless @from && @to
          raise ArgumentError, 'You need to set :from and :to to send emails.'
        end
      end

      def notify(outpost)
        mail         = Mail.new
        mail.from    = @from
        mail.to      = @to
        mail.subject = @subject
        mail.body    = build_message(outpost)

        mail.deliver
      end

      private
      def build_message(outpost)
        status = outpost.last_status.to_s

        message  = "This is the report for #{outpost.name}: "
        message += "System is #{status.upcase}!\n\n"

        message += outpost.messages.join("\n")
      end
    end
  end
end

