module Outpost
  module Scout
    class Config
      attr_reader :options, :reports

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
      # an inverted approach:
      #
      # {{:response_code => 200} => :up}
      def report(status, params)
        @reports ||= {}
        @reports[params] = status
      end
    end
  end
end
