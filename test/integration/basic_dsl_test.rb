require 'test_helper'

require 'outpost/scouts/http_scout'

describe "basic DSL integration test" do
  class ExampleSuccess < Outpost::DSL
    depends Outpost::HttpScout => 'master http server' do
      options :host => 'example.com'
      report :up, :response_code => 200
    end
  end

  class ExampleFailure < Outpost::DSL
    depends Outpost::HttpScout => 'master http server' do
      # Google will return 301, so it will fail
      options :host => 'google.com'
      report :up, :response_code => 200
    end
  end

  it "should report up when everything's ok" do
    assert_equal :up, ExampleSuccess.new.run
  end

  it "should report failure when something's wrong" do
    assert_equal :down, ExampleFailure.new.run
  end
end
