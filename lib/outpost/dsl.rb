module Outpost
  # This class is the basic structure of an Outpost application. It provides
  # the basic DSL for you to configure the monitoring of your services.
  # Example:
  #
  #  class ExampleSuccess < Outpost::DSL
  #    name "Example"
  #    using Outpost::Scouts::Http => 'master http server' do
  #      options :host => 'localhost', :port => 9595
  #      report :up, :response_code => 200
  #    end
  #  end
  #
  # @abstract
  class DSL
    class << self
      # Returns all the registered scouts.
      attr_reader :scouts

      # Returns all the registered notifiers.
      attr_reader :notifiers

      # Register a scout in the list of scouts.
      #
      # @param [Hash{Scout => String}, #read] scout_description A hash
      #   containing Scout class as key and its description as a value.
      # @yield Block to be evaluated to configure the current {Scout}.
      def using(scout_description, &block)
        @scouts ||= Hash.new { |h, k| h[k] = {} }

        config = ScoutConfig.new
        config.instance_eval(&block)

        scout_description.each do |scout, description|
          @scouts[scout][:description] = description
          @scouts[scout][:config]      = config
        end
      end

      # Register a notifier class in the list of notifications.
      #
      # @param [{Class}, #read] class A class that will be used to issue
      #   a notification. The class must accept a configuration hash in the
      #   constructor and also implement a #notify method that will receive an
      #   outpost instance. See {Outpost::Notifiers::Email} for an example.
      #
      # @param [Hash, #read] options Options that will be used to configure the
      #   notification class.
      def notify(notifier, options={})
        @notifiers           ||= {}
        @notifiers[notifier]   = options
      end

      # Set the name of the scout. Can be used by notifiers in order to have
      # a better description of the service in question.
      # @param [String, #read] name The name to be given to a Outpost-based
      #   class.
      def name(val=nil)
        if val
          @name = val
        else
          @name
        end
      end
    end

    # Returns the status of the last service check or nil if it didn't happen.
    attr_reader :last_status

    # Returns a list of {Report} containing the last results of the last check.
    attr_reader :reports

    # New instance of a Outpost-based class.
    def initialize
      @reports     = []
      @last_status = nil
    end

    # Execute all the scouts associated with an Outpost-based class and returns
    # either :up or :down, depending of the results.
    def run
      @reports = self.class.scouts.map do |scout, options|
        run_scout(scout, options)
      end

      statuses = @reports.map { |r| r.status }

      @last_status = Report.summarize(statuses)
    end

    # Runs all notifications associated with an Outpost-based class.
    def notify
      if reports.any?
        self.class.notifiers.each do |notifier, options|
          # .dup is NOT reliable
          options_copy = Marshal.load(Marshal.dump(options))
          notifier.new(options_copy).notify(self)
        end
      end
    end

    # Returns true if the last status is :up
    def up?
      @last_status == :up
    end

    # Returns true if the last status is :down
    def down?
      @last_status == :down
    end

    # Returns the name of an Outpost-based class or the class name itself if
    # not set.
    def name
      self.class.name || self.class.to_s
    end

    # Returns the messages of the latest service check.
    def messages
      reports.map { |r| r.to_s }
    end

    private

    # :nodoc:
    def run_scout(scout, options)
      scout_instance = scout.new(options[:description], options[:config])

      params = {
        :name        => scout.name,
        :description => options[:description],
        :status      => scout_instance.run
      }
      Report.new(params)
    end
  end
end
