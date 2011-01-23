module Outpost
  module ResponseBodyHook
    def self.extended(base)
      base.class_eval do
        register_hook :response_body, method(:evaluate_response_body)
      end
    end

    def evaluate_response_body(scout, rules)
      rules.all? do |rule,comparison|
        case rule
        when :match
          scout.response_body =~ comparison
        when :not_match
          !scout.response_body =~ comparison
        when :equals
          scout.response_body == comparison
        when :differs
          scout.response_body != comparison
        end
      end
    end
  end
end
