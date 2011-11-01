module Outpost
  # This class is the basic structure of an Outpost application. It provides
  # the basic DSL for you to configure the monitoring of your services.
  # Example:
  #
  #  class ExampleSuccess < Outpost::Application
  #    name "Example"
  #    using Outpost::Scouts::Http => 'master http server' do
  #      options :host => 'localhost', :port => 9595
  #      report :up, :response_code => 200
  #    end
  #  end
  #
  # The above example will set templates and every new instance of
  # ExampleSuccess will have the same behavior. But all the methods
  # are available to instances, so it is also possible to create Outpost
  # applications as the following example:
  #
  #  my_outpost = Outpost::Application.new
  #  my_outpost.name = 'Example'
  #
  #  my_outpost.using(Outpost::Scouts::Http => 'master http server') do
  #    options :host => 'localhost', :port => 9595
  #    report :up, :response_code => 200
  #  end
  class Application
    class << self
      def scout_templates
        @scout_templates || []
      end

      def notifier_templates
        @notifier_templates || []
      end

      def name_template
        @name_template || self.to_s
      end

      # Register a scout in the list of scouts.
      #
      # @param [Hash{Scout => String}, #read] scout_description A hash
      #   containing Scout class as key and its description as a value.
      #
      # @yield Block to be evaluated to configure the current {Scout}.
      def using(scout_description, &block)
        @scout_templates ||= []
        @scout_templates << {
          :scout_description => scout_description,
          :block => block
        }
      end

      # Register a notifier class in the list of notifications.
      #
      # @param [Class, #read] class A class that will be used to issue
      #   a notification. The class must accept a configuration hash in the
      #   constructor and also implement a #notify method that will receive an
      #   outpost instance. See {Outpost::Notifiers::Email} for an example.
      #
      # @param [Hash, #read] options Options that will be used to configure the
      #   notification class.
      def notify(notifier, options={})
        @notifier_templates ||= []
        @notifier_templates << {:notifier => notifier, :options => options}
      end

      # Set the name of the scout. Can be used by notifiers in order to have
      # a better description of the service in question.
      #
      # @param [String, #read] name The name to be given to a Outpost-based
      #   class.
      def name(val=nil)
        @name_template = val if val
        @name_template
      end
    end

    # Returns the status of the last service check or nil if it didn't happen.
    attr_reader :last_status

    # Returns a list of {Report} containing the last results of the last check.
    attr_reader :reports

    # Returns all the registered scouts.
    attr_reader :scouts

    # Returns all the registered notifiers.
    attr_reader :notifiers

    # Reader/setter for the name of this scout
    attr_accessor :name

    # New instance of a Outpost-based class.
    def initialize
      @reports     = {}
      @last_status = nil
      @scouts      = []
      @notifiers   = {}
      @name        = self.class.name_template

      # Register scouts
      self.class.scout_templates.each do |template|
        add_scout(template[:scout_description], &template[:block])
      end

      self.class.notifier_templates.each do |template|
        add_notifier(template[:notifier], template[:options])
      end
    end

    # @see Application#using
    def add_scout(scout_description, &block)
      config = ScoutConfig.new
      config.instance_eval(&block)

      scout_description.each do |scout, description|
        @scouts << [ scout, :description => description, :config => config ]
      end
    end

    # @see Application#notify
    def add_notifier(notifier_name, options)
      @notifiers[notifier_name] = options
    end

    # Execute all the scouts associated with an Outpost-based class and returns
    # either :up or :down, depending on the results.
    def run
      scouts.map do |scout, options|
        @reports[options[:description]] = run_scout(scout, options)
      end

      statuses = @reports.map { |_, r| r.status }

      @last_status = Report.summarize(statuses)
    end

    # Runs all notifications associated with an Outpost-based class.
    def notify
      if reports.any?
        @notifiers.each do |notifier, options|
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

    # Returns true if the last status is :warning
    def warning?
      @last_status == :warning
    end

    # Returns true if the last status is :down
    def down?
      @last_status == :down
    end

    # Returns the messages of the latest service check.
    #
    # @return [Array<String>] An array containing all report messages.
    def messages
      reports.map { |_, r| r.to_s }
    end

    private

    # :nodoc:
    def run_scout(scout, options)
      scout_instance = scout.new(options[:description], options[:config])

      params = {
        :name        => scout.name,
        :description => options[:description],
        :status      => scout_instance.run,
        :data        => scout_instance.report_data
      }
      Report.new(params)
    end
  end
end
