module Outpost
  class DSL
    class << self
      attr_reader :scouts

      def depends(scouts, &block)
        @scouts ||= {}

        config = Scout::Config.new
        config.instance_eval(&block)

        scouts.each do |scout, description|
          @scouts[scout]               ||= {}
          @scouts[scout][:description]   = description
          @scouts[scout][:config]        = config
        end
      end
    end

    def run
      statuses = self.class.scouts.map do |scout, options|
        scout_instance = scout.new(options[:description], options[:config])
        scout_instance.run
      end

      Report.summarize(statuses)
    end
  end
end
