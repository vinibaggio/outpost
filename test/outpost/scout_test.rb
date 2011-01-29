require 'test_helper'
require 'ostruct'

describe Outpost::Scout do
  NoisyError = Class.new(StandardError)

  class ScoutExample < Outpost::Scout
    attr_accessor :response
    register_hook :response, lambda {|scout, status| scout.response == status }

    def setup(*args); end
    def execute(*args); end
  end

  it "should report up when status match" do
    scout = ScoutExample.new("a scout", config_mock)
    scout.response = true
    assert_equal :up, scout.run
  end

  it "should report up when status match" do
    scout = ScoutExample.new("a scout", config_mock)
    scout.response = false
    assert_equal :down, scout.run
  end

  it "should not register an invalid hook" do
    assert_raises ArgumentError do
      add_hook(:invalid_hook, nil)
    end
  end

  it "should register a hook using a lambda" do
    add_hook(:valid_hook, lambda{|b| b})

    refute_nil ScoutExample.hooks[:valid_hook]
  end

  it "should register a hook using pure blocks for flexibility" do
    ScoutExample.register_hook(:valid_hook) { |b| b }

    refute_nil ScoutExample.hooks[:valid_hook]
  end

  it "should not be able to have its hooks modified" do
    ScoutExample.hooks[:another_hook] = {}
    assert_nil ScoutExample.hooks[:another_hook]
  end

  it "should not call hook when there are no rules for that" do
    add_hook(:noisy, proc {|s,r| raise NoisyError})
    assert_nothing_raised do
      scout = ScoutExample.new("a scout", config_mock)
      scout.run
    end
  end

  it "should call hook when there are rules for that" do
    add_hook(:noisy, proc {|s,r| raise NoisyError})
    config = config_mock
    config.reports[{:noisy => nil}] = :down

    assert_raises NoisyError do
      scout = ScoutExample.new("a scout", config)
      scout.run
    end
  end

  it "should complain when an unregistered hook is called" do
    config = config_mock
    config.reports[{:unregistered => nil}] = :up

    assert_raises NotImplementedError do
      scout = ScoutExample.new("a scout", config)
      scout.run
    end
  end

  private
  def config_mock
    OpenStruct.new.tap do |config|
      config.reports = {}
      config.reports[{:response => true}] = :up
      config.reports[{:response => false}] = :down
    end
  end

  def add_hook(hook, callable)
    ScoutExample.register_hook hook, callable
  end
end
