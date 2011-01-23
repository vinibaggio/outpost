module Outpost
  module ResponseCodeHook
    def self.extended(base)
      base.class_eval do
        register_hook :response_code, method(:evaluate_response_code)
      end
    end

    def evaluate_response_code(scout, response_code)
      scout.response_code == response_code.to_i
    end
  end
end
