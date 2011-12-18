module Outpost
  module Expectations
    # Module containing response_time matching expectations. Extend your Scout
    # with ResponseTime and it will evaluate timely expressions, all in
    # milisseconds.
    #
    # It respond to the following rules:
    # * less_than => If the response time is less than the associated number
    # * more_than => If the response time is below than the associated number
    module ResponseTime
      RESPONSE_TIME_MAPPING = {
        :less_than => "<",
        :more_than => ">",
      }.freeze

      # Installs the response time expectation
      def self.extended(base)
        base.expect :response_time, base.method(:evaluate_response_time)
      end

      # Method that will be used as an expectation to evaluate response time
      def evaluate_response_time(scout, rules)
        rules.all? do |rule, comparison|
          scout.response_time.nil? ? false : scout.response_time.send(RESPONSE_TIME_MAPPING[rule], comparison)
        end
      end
    end
  end
end
