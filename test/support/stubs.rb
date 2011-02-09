module Support
  module Stubs
    def build_stub(params={})
      OpenStruct.new.tap do |stub|
        params.each do |key, val|
          stub.send "#{key}=", val
        end
      end
    end
  end
end
