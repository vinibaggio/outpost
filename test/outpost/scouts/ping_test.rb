require 'test_helper'

describe Outpost::Scouts::Ping do
  class PingStub
    def initialize(ping_successful, duration=nil)
      @ping_successful = ping_successful
      @duration        = duration
    end

    def ping(*args); @ping_successful; end
    def duration;    @duration;        end
  end

  before(:each) do
    config   = config_stub(:host => 'localhost')
    @subject = Outpost::Scouts::Ping.new "test", config
  end

  it "should set the time of ping in milliseconds" do
    @subject.execute(PingStub.new(true, 0.225))

    assert_equal 225, @subject.response_time
  end

  it "should set the time to nil when it fails" do
    @subject.execute(PingStub.new(false))

    refute @subject.response_time
  end

  private

  def config_stub(options={})
    OpenStruct.new.tap do |stub|
      stub.options = options
    end
  end

  def pinger_stub(should_respond, time=nil)
    OpenStruct.new.tap do |stub|
      stub.ping     = should_respond
      stub.duration = time
    end
  end
end
