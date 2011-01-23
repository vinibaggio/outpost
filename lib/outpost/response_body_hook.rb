module Outpost
  module ResponseBodyHook
    def self.extended(base)
      base.class_eval do
        register_hook :response_body, method(:evaluate_response_body)
      end
    end

    def evaluate_response_body(scout, rules)
      rules.all? do |rule,comparison|
        operator = case rule
        when :match
          "=~"
        when :not_match
          "!~"
        when :equals
          "=="
        when :differs
          "!="
        end
        scout.response_body.send(operator, comparison)
      end
    end
  end
end
