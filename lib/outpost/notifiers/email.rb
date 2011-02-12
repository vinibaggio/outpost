begin
  require 'mail'
rescue LoadError => e
  puts "Please install mail gem: gem install mail"
  raise
end

module Outpost
  module Notifiers
    # The Email notifier issues Outpost notifications to through email.  It
    # uses the 'mail' gem send the emails. You can see mail's documentation
    # in order to change how emails will be delivered:
    # https://github.com/mikel/mail
    #
    # This requires the 'mail' gem to be installed.
    class Email

      # @param [Hash] Options to create an email notification.
      # @option options [String] :from The "from" email field
      # @option options [String] :to Where e-mails will be delivered
      # @option options [String] :subject The email's subject
      def initialize(options={})
        @from    = options[:from]
        @to      = options[:to]
        @subject = options[:subject] || 'Outpost notification'

        unless @from && @to
          raise ArgumentError, 'You need to set :from and :to to send emails.'
        end
      end

      # Issues a notification through email. This is a callback, called by
      # an Outpost instance.
      # @param [Outpost::Application, #read] outpost an instance of an outpost, containing
      #   latest status, messages and reports that can be queried to build
      #   a notification message.
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

