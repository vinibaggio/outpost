module Outpost
  class DSL
    class << self
      def depends(scouts, &block)
        @services ||= []
        @services += scouts.map do |scout, description|
          options = ScoutOptions.new
          options.instance_eval(block)

          scout.new(description, options)
        end
      end
    end
  end
end
