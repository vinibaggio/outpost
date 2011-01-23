require 'test_helper'

describe Outpost::DSL do
  class ExampleOne < Outpost::DSL
    depends Object => 'master http server' do
      options :host => 'localhost'
      report :up, :response_code => 200
    end
  end

  before(:each) do
    @scouts = ExampleOne.scouts
  end

  it "should create correct scout description" do
    assert_equal(Object, @scouts.keys.first)
    assert_equal('master http server', @scouts[Object][:description])
  end

  it "should create correct scout config" do
    config = @scouts[Object][:config]
    assert_equal({:host => 'localhost'}, config.options)
    assert_equal({{:response_code => 200} => :up}, config.reports)
  end
end
