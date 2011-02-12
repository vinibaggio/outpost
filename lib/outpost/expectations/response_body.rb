module Outpost
  module Expectations
    # Module containing response_body matching expectations. Extend your Scout
    # with ResponseBody and it will gain response_body evaluation powers!
    #
    # It respond to the following rules:
    # * match => If the response body matches the associated regular expression
    # * not_match => If the response body does not match the associated regular
    #   expression
    # * equals => If the response body matches exactly the associated string
    # * differs => If the response body differs in any way the associated
    #   string.
    module ResponseBody
      # Installs the response body expectation
      def self.extended(base)
        base.expect :response_body, base.method(:evaluate_response_body)
      end

      # Method that will be used as an expectation to evaluate response body
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
