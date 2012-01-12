require 'test_helper'

describe Outpost::Scouts::Tcp do
  it "should set the time of ping in milliseconds" do
    cls = Class.new do
      def initialize(host, port, timeout)
      end

      def duration
        0.01
      end

      def ping? 
        true
      end
    end

    config = config_stub(:port => 9595, :pinger => cls)
    subject = Outpost::Scouts::Tcp.new "test", config
    subject.execute

    assert subject.response_time.to_i < 100
  end

  it "should set the time to nil when it fails" do
    #nothing uses this port by deafult
    config = config_stub(:port => 16)
    subject = Outpost::Scouts::Tcp.new "test", config
    subject.execute

    assert subject.response_time.nil?
  end

  private

  def config_stub(options={})
    options = {:host => 'localhost'}.merge options

    build_stub(:options => options)
  end  
end
