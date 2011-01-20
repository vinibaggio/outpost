module Outpost
  module Scout
    class Base

      def initialize(description, config)
        @description = description
        @config      = config
        setup(config.options)
      end

      def run
        statuses = []
        response = execute
        @config.reports.each do |response_pair, status|
          response_pair.each do |attribute, value|
            if send(attribute) == value
              statuses << status
            end
          end
        end

        Report.summarize(statuses)
      end

      def setup
        raise NotImplementedError, 'You must implement the setup method for Scout to work correctly.'
      end
      def execute
        raise NotImplementedError, 'You must implement the execute method for Scout to work correctly.'
      end

    end
  end
end
