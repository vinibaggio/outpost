require 'test_helper'

describe Outpost::Scouts::Http do
  class NetHttpStub
    class << self
      def response(&block); @response = block; end

      def get_response(*args)
        @response.call
      end
    end
  end

  before(:each) do
    config_stub = config_stub(:host => 'localhost')
    @subject    = Outpost::Scouts::Http.new("description", config_stub)
  end

  it "should get the response code and response body" do
    NetHttpStub.response { response_stub('200', 'Body') }
    @subject.execute(NetHttpStub)

    assert_equal 200   , @subject.response_code
    assert_equal 'Body', @subject.response_body
  end

  it "should set response code and body as nil when connection refused" do
    NetHttpStub.response { raise Errno::ECONNREFUSED }
    @subject.execute(NetHttpStub)

    refute @subject.response_code
    refute @subject.response_body
  end

  it "should set response code and body as nil when socket error" do
    NetHttpStub.response { raise SocketError }

    refute @subject.response_code
    refute @subject.response_body
  end


  private

  def config_stub(options={})
    OpenStruct.new.tap do |stub|
      stub.options = options
    end
  end

  def response_stub(code, body)
    OpenStruct.new.tap do |stub|
      stub.code = code
      stub.body = body
    end
  end

end
