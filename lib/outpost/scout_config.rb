module Outpost
  class ScoutConfig
    attr_reader :options, :reports

    def initialize
      @reports = {}
    end

    # Reads/writes any options. It will passed
    # down to the scout.
    def options(args=nil)
      if args.nil?
        @options
      else
        @options = args
      end
    end

    # Reads reporting as:
    #   report :up, :response_code => 200
    #
    # It reads much better in the DSL, but doesn't make
    # much sense in terms of code, so it is changed to
    # an inverted approach, so:
    #   status = 200
    #   params = {:response_code => 200}
    #
    #   gets stored as:
    #    {:response_code => 200} = up
    def report(status, params)
      @reports[params] = status
    end
  end
end
