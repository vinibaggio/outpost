module Outpost
  class Scout
    class << self

      def hooks
        @hooks.dup
      end

      private
      # Should be only callable by the class itself and not externally
      def register_hook(hook, callable)
        if callable.respond_to?(:call)
          @hooks ||= {}
          @hooks[hook] = callable
        else
          raise ArgumentError, 'Object must respond to method #call to be a valid hook.'
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
      response = execute
      @config.reports.each do |response_pair, status|
        response_pair.each do |attribute, value|
          if self.class.hooks[attribute].call(self, value)
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
