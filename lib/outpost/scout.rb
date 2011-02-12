module Outpost
  # Scouts are responsible for gathering data about a something specific that is
  # a part of your system. For example, a HTTP Scout is responsible for getting
  # the response code (200 for OK, 404 for Page Not Found, etc.), response
  # body and any other thing you might want to know.
  #
  #
  # Scouts must also contain expectations. They must be registered into the
  # Scout that wish to support different types of expectations. You can supply
  # a block or an object that respond to #call and return true if any of the
  # rules match. It will receive an instance of the scout (so you can query
  # current system state) as the first parameter and the state defined by the
  # Outpost as the second.
  #
  #
  # Example:
  #   expect(:response_code) do |scout, code|
  #     scout.response_code == code
  #   end
  #
  # @example an example of a Scout that parses the HTTP response code
  #   module Outpost
  #     module Scouts
  #       class Http < Outpost::Scout
  #         expect(:response_code) { |scout,code| scout.response_code == code }
  #
  #         attr_reader :response_code
  #
  #         def setup(options)
  #           @host = options[:host]
  #           @port = options[:port] || 80
  #           @path = options[:path] || '/'
  #         end
  #
  #         def execute
  #           response = Net::HTTP.get_response(@host, @path, @port)
  #           @response_code = response.code.to_i
  #         end
  #       end
  #     end
  #   end
  #
  # @abstract Subclasses must override {#setup} and {#execute} to be a valid
  #   Scout
  class Scout
    class << self

      # Returns the hash of expectations, where the key is the name of the
      # expectation and the value is the callable Object (object that responds
      # to #call)
      #
      # @return [Hash<Symbol, Object>]
      def expectations
        @expectations ? @expectations.dup : []
      end

      # Registers a new expectation into the Scout. If the callable does not
      # respond to #call, an ArgumentError will be raised.
      #
      # @param [Symbol, #read] expectation The name of the expectation
      #   (examples: :response_code, :response_time)
      # @param [Object, #read] callable An object that responds to call and
      #   returns a Boolean. It will be executed whenever a Scout is run.
      #   A block is also accepted.
      # @raise [ArgumentError] raised when the callable parameter does not
      #   respond to #call method.
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

    # @param [String, #read] description A string containing a description of
    #   the Scout so it may be identified in the construction of status reports.
    # @param [Hash, #read] config A hash containing any number of
    #   configurations that will be passed to the #setup method
    def initialize(description, config)
      @description = description
      @config      = config

      setup(config.options)
    end

    # Executes the Scout and go through all the registered expectations to find
    # out all expectations that match and return the associated status.
    #
    # @return [Symbol] the current status of the Scout (:up, :down)
    # @raise [NotImplementedError] raised when a configured expectation was not
    #   registered in the Scout.
    def run
      statuses = []
      execute
      # Response_pair contains the expectation as key and the expected value as
      # value.
      # Example: {:response_time => 200}
      #
      # status is the status (:up or :down, for example) that will be returned
      # in case the expectation match current system status.
      @config.reports.each do |response_pair, status|
        response_pair.each do |expectation, value|
          if self.class.expectations[expectation].nil?
            message = "expectation '#{expectation}' wasn't implemented by #{self.class.name}"
            raise NotImplementedError, message
          end

          if self.class.expectations[expectation].call(self, value)
            statuses << status
          end
        end
      end

      Report.summarize(statuses)
    end

    # Called when the scout object is being constructed. Arguments can be
    # everything the developer set in the creation of Outpost.
    #
    # @raise [NotImplementedError] raised when method is not overriden.
    def setup(*args)
      raise NotImplementedError, 'You must implement the setup method for Scout to work correctly.'
    end

    # Called when the Scout must take action and gather all the data needed to
    # be analyzed.
    #
    # @raise [NotImplementedError] raised when method is not overriden.
    def execute(*args)
      raise NotImplementedError, 'You must implement the execute method for Scout to work correctly.'
    end

  end
end
