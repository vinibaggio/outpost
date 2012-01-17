require 'test_helper'
require 'ostruct'

describe Outpost::Scouts::Http do
  class NetHttpStub
    class << self
      def response(&block); @response = block; end

      def get_response(*args)
        @response.call
      end

      def request_head(*args)
        throw "Unexpected call"
      end
    end
  end

  class NetHttpHeadStub < NetHttpStub
    class << self
      def request_head(*args)
        OpenStruct.new :code => 200, :body => 'Body'
      end

      def get_response(*args)
        throw "Unexpected call"
      end
    end
  end

  before(:each) do
    config_stub = config_stub(:host => 'localhost', :http_class => NetHttpStub)
    @subject    = Outpost::Scouts::Http.new("description", config_stub)
  end

  it "should get the response code and response body" do
    NetHttpStub.response { response_stub('200', 'Body') }
    @subject.execute

    assert_equal 200   , @subject.response_code
    assert_equal 'Body', @subject.response_body
  end

  it "should set the reporting data accordingly" do
    NetHttpStub.response { response_stub('200', 'Body') }
    @subject.run

    assert_equal 200   , @subject.report_data[:response_code]
    assert_equal 'Body', @subject.report_data[:response_body]
  end

  it "should set response code and body as nil when connection refused" do
    NetHttpStub.response { raise Errno::ECONNREFUSED }
    @subject.execute

    refute @subject.response_code
    refute @subject.response_body
  end

  it "should set response code and body as nil when socket error" do
    NetHttpStub.response { raise SocketError }

    refute @subject.response_code
    refute @subject.response_body
  end

  it "should make HEAD request if option is passed" do
    config_stub = config_stub(:host => 'localhost', :http_class => NetHttpHeadStub, :request_head => true)
    @subject    = Outpost::Scouts::Http.new("description", config_stub)

    @subject.run

    assert_equal 200   , @subject.response_code
    assert_equal 'Body', @subject.response_body    
  end

  private

  def config_stub(options={})
    build_stub(:options => options)
  end

  def response_stub(code, body)
    build_stub(:code => code, :body => body)
  end
end
