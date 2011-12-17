module Outpost
  module Expectations
    # Module containing response_code logic. It is the simplest of all,
    # it is a simple direct equality check. Extend your Scout to win instant
    # response_code checking.
    module ResponseCode
      # Installs the response code expectation
      def self.extended(base)
        base.expect :response_code, base.method(:evaluate_response_code)
      end

      # Method that will be used as an expectation to evaluate response code
      def evaluate_response_code(scout, response_code)
        if response_code.is_a?(Array) || response_code.is_a?(Range)
          response_code.include?(scout.response_code)
        else
          scout.response_code == response_code.to_i
        end
      end
    end
  end
end
