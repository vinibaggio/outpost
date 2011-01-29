module Outpost
  module ResponseCodeHook
    def self.extended(base)
      base.register_hook :response_code, base.method(:evaluate_response_code)
    end

    def evaluate_response_code(scout, response_code)
      scout.response_code == response_code.to_i
    end
  end
end
