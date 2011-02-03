module Outpost
  class DSL
    class << self
      attr_reader :scouts, :notifiers

      def using(scouts, &block)
        @scouts ||= Hash.new { |h, k| h[k] = {} }

        config = ScoutConfig.new
        config.instance_eval(&block)

        scouts.each do |scout, description|
          @scouts[scout][:description] = description
          @scouts[scout][:config]      = config
        end
      end

      def notify(notifier, options={})
        @notifiers           ||= {}
        @notifiers[notifier]   = options
      end

      def name(val=nil)
        if val
          @name = val
        else
          @name
        end
      end
    end

    attr_reader :last_status, :reports

    def initialize
      @reports     = []
      @last_status = nil
    end

    def run
      @reports = self.class.scouts.map do |scout, options|
        run_scout(scout, options)
      end

      statuses = @reports.map { |r| r.status }

      @last_status = Report.summarize(statuses)
    end

    def notify
      if reports.any?
        self.class.notifiers.each do |notifier, options|
          # .dup is NOT reliable
          options_copy = Marshal.load(Marshal.dump(options))
          notifier.new(options_copy).notify(self)
        end
      end
    end

    def up?
      @last_status == :up
    end

    def down?
      @last_status == :down
    end

    def name
      self.class.name || self.class.to_s
    end

    def messages
      reports.map { |r| r.to_s }
    end

    private

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
