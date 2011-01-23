require 'test_helper'

describe Outpost::ScoutConfig do
  before(:each) do
    @config = Outpost::ScoutConfig.new
  end

  it "should assign options accordingly" do
    @config.options :host => 'localhost'

    assert_equal({:host => 'localhost'}, @config.options)
  end

  it "should assign reports accordingly" do
    @config.report :up, :response_code => 200

    assert_equal({{:response_code => 200} => :up}, @config.reports)
  end

  it "should assign multiple reports" do
    @config.report :up, :response_code => 200
    @config.report :down, :response_code => 404

    assert_equal({
        {:response_code => 200} => :up,
        {:response_code => 404} => :down,
      }, @config.reports)
  end
end
