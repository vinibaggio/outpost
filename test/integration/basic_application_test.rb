require 'test_helper'

require 'outpost/scouts/http'

describe "basic application integration test" do
  before(:each) do
    @server = Server.new
    @server.boot(TestApp)

    while !@server.responsive?
      sleep 0.1
    end
  end

  class ExampleSuccess < Outpost::Application
    using Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595
      report :up, :response_code => 200
    end
  end

  class ExampleFailure < Outpost::Application
    using Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/fail'
      report :up, :response_code => 200
    end
  end

  class ExampleBodyFailure < Outpost::Application
    using Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/fail'
      report :down, :response_body => {:equals => 'Omg fail'}
    end
  end

  class ExampleBodySuccess < Outpost::Application
    using Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/'
      report :up, :response_body => {:match => /Up/}
    end
  end

  it "should report up when everything's ok" do
    assert_equal :up, ExampleSuccess.new.run
  end

  it "should report failure when something's wrong" do
    assert_equal :down, ExampleFailure.new.run
  end

  it "should report success when body is okay" do
    assert_equal :up, ExampleBodySuccess.new.run
  end

  it "should report failure when body is wrong" do
    assert_equal :down, ExampleBodyFailure.new.run
  end
end
