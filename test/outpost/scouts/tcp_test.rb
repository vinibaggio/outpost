require 'test_helper'

describe Outpost::Scouts::Tcp do
  it "should set the time of ping in milliseconds" do
    @server = Server.new
    @server.boot(TestApp)
    @server.wait_until_booted

    config = config_stub(:port => 9595)
    subject = Outpost::Scouts::Tcp.new "test", config
    subject.execute

    assert subject.response_time < 1
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
