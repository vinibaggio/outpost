require 'test_helper'

require 'outpost/http_scout'

describe "basic DSL integration test" do
  class ExampleSuccess < Outpost::DSL
    depends Outpost::HttpScout => 'master http server' do
      options :host => 'localhost', :port => 9595
      report :up, :response_code => 200
    end
  end

  class ExampleFailure < Outpost::DSL
    depends Outpost::HttpScout => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/fail'
      report :up, :response_code => 200
    end
  end

  class ExampleBodyFailure < Outpost::DSL
    depends Outpost::HttpScout => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/fail'
      report :down, :response_body => {:equals => 'Omg fail'}
    end
  end

  class ExampleBodySuccess < Outpost::DSL
    depends Outpost::HttpScout => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/fail'
      report :up, :response_body => {:match => /Hello/}
    end
  end

  it "should report up when everything's ok" do
    assert_equal :up, ExampleSuccess.new.run
  end

  it "should report failure when something's wrong" do
    assert_equal :down, ExampleFailure.new.run
  end

  it "should report success when body is okay" do
    assert_equal :down, ExampleBodySuccess.new.run
  end

  it "should report failure when body is wrong" do
    assert_equal :down, ExampleBodyFailure.new.run
  end
end
