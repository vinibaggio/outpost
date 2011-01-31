module Outpost
  module Expectations
    module ResponseTime
      RESPONSE_TIME_MAPPING = {
        :less_than => "<",
        :more_than => ">",
      }.freeze

      def self.extended(base)
        base.expect :response_time, base.method(:evaluate_response_time)
      end

      def evaluate_response_time(scout, rules)
        rules.all? do |rule,comparison|
          scout.response_time.send(RESPONSE_TIME_MAPPING[rule], comparison)
        end
      end
    end
  end
end
