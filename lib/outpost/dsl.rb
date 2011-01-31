module Outpost
  class DSL
    class << self
      attr_reader :scouts

      def using(scouts, &block)
        @scouts ||= {}

        config = ScoutConfig.new
        config.instance_eval(&block)

        scouts.each do |scout, description|
          @scouts[scout]               ||= {}
          @scouts[scout][:description]   = description
          @scouts[scout][:config]        = config
        end
      end
    end

    attr_reader :last_status

    def run
      statuses = self.class.scouts.map do |scout, options|
        scout_instance = scout.new(options[:description], options[:config])
        scout_instance.run
      end

      @last_status = Report.summarize(statuses)
    end

    def up?
      @last_status == :up
    end

    def down?
      @last_status == :down
    end
  end
end
