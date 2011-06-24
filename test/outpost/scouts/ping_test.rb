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

  it "should set the time of ping in milliseconds" do
    config  = config_stub(:pinger => PingStub.new(true, 0.225))
    subject = Outpost::Scouts::Ping.new "test", config
    subject.execute

    assert_equal 225, subject.response_time
  end

  it "should set the time to nil when it fails" do
    config  = config_stub(:pinger => PingStub.new(false))
    subject = Outpost::Scouts::Ping.new "test", config
    subject.execute

    refute subject.response_time
  end

  it "should report the response time" do
    config  = config_stub(:pinger => PingStub.new(true, 0.225))
    subject = Outpost::Scouts::Ping.new "test", config
    subject.run

    assert_equal 225, subject.report_data[:response_time]
  end

  private

  def config_stub(options={})
    options = {:host => 'localhost'}.merge options

    build_stub(:options => options)
  end

  def pinger_stub(should_respond, time=nil)
    build_stub(:ping => should_respond, :duration => time)
  end
end
