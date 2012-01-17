require 'test_helper'

require 'outpost/scouts/http'

describe "basic application integration test" do
  class ExampleSuccess < Outpost::Application
    using Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595
      report :up, :response_code => 200
    end
  end

  class ExampleWarning < Outpost::Application
    using Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/warning'
      report :warning, :response_code => 402
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

  class ExampleBodyWarning < Outpost::Application
    using Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/warning'
      report :warning, :response_body => {:equals => 'Omg need payment'}
    end
  end

  it "should report up when everything's ok" do
    assert_equal :up, ExampleSuccess.new.run
  end

  it "should report warning when there's a warning" do
    assert_equal :warning, ExampleWarning.new.run
  end

  it "should report failure when something's wrong" do
    assert_equal :down, ExampleFailure.new.run
  end

  it "should report success when body is okay" do
    assert_equal :up, ExampleBodySuccess.new.run
  end

  it "should report success when body have a warning" do
    assert_equal :warning, ExampleBodyWarning.new.run
  end

  it "should report failure when body is wrong" do
    assert_equal :down, ExampleBodyFailure.new.run
  end
end
