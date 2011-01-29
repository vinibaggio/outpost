module Outpost
  class Scout
    class << self

      def expectations
        @expectations ? @expectations.dup : []
      end

      def expect(expectation, callable=nil, &callable_block)
        callable ||= callable_block

        if callable.respond_to?(:call)
          @expectations ||= {}
          @expectations[expectation] = callable
        else
          raise ArgumentError, 'Object must respond to method #call to be a valid expectation.'
        end
      end
    end

    def initialize(description, config)
      @description = description
      @config      = config

      setup(config.options)
    end

    def run
      statuses = []
      execute
      @config.reports.each do |response_pair, status|
        response_pair.each do |attribute, value|
          if self.class.expectations[attribute].nil?
            message = "expectation '#{attribute}' wasn't implemented by #{self.class.name}"
            raise NotImplementedError, message
          end

          if self.class.expectations[attribute].call(self, value)
            statuses << status
          end
        end
      end

      Report.summarize(statuses)
    end

    def setup(*args)
      raise NotImplementedError, 'You must implement the setup method for Scout to work correctly.'
    end

    def execute(*args)
      raise NotImplementedError, 'You must implement the execute method for Scout to work correctly.'
    end

  end
end
