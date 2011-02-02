module Outpost
  module Expectations
    module ResponseBody
      RESPONSE_BODY_MAPPING = {
        :match     => "=~",
        :not_match => "!~",
        :equals    => "==",
        :differs   => "!="
      }.freeze

      def self.extended(base)
        base.expect :response_body, base.method(:evaluate_response_body)
      end

      def evaluate_response_body(scout, rules)
        rules.all? do |rule, comparison|
          case rule
          when :match
            scout.response_body =~ comparison
          when :not_match
            scout.response_body !~ comparison
          when :equals
            scout.response_body == comparison
          when :differs
            scout.response_body != comparison
          end
        end
      end
    end
  end
end
