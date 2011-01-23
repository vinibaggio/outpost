require 'test_helper'
require 'ostruct'

class ScoutTest < Test::Unit::TestCase
  NoisyError = Class.new(StandardError)

  class ScoutExample < Outpost::Scout
    attr_accessor :response
    register_hook :response, lambda {|scout, status| scout.response == status }

    def setup(*args); end
    def execute(*args); end
  end

  def test_run_positively
    scout = ScoutExample.new("a scout", config_mock)
    scout.response = true
    assert_equal :up, scout.run
  end

  def test_run_negatively
    scout = ScoutExample.new("a scout", config_mock)
    scout.response = false
    assert_equal :down, scout.run
  end

  def test_registered_hook
    assert_not_nil ScoutExample.hooks[:response]
  end

  def test_register_invalid_hook
    assert_raise ArgumentError do
      add_hook(:invalid_hook, nil)
    end
  end

  def test_register_valid_hook
    add_hook(:valid_hook, lambda{|b| b})

    assert_not_nil ScoutExample.hooks[:valid_hook]
  end

  def test_try_to_modify_hooks
    ScoutExample.hooks[:another_hook] = {}
    assert_nil ScoutExample.hooks[:another_hook]
  end

  def test_try_to_register_hook_from_outside
    assert_raise NoMethodError do
      ScoutExample.register_hook :a, lambda {}
    end
  end

  def test_do_not_call_noisy_if_no_rules_were_made
    add_hook(:noisy, proc {|s,r| raise NoisyError})
    assert_nothing_raised NoisyError do
      scout = ScoutExample.new("a scout", config_mock)
      scout.run
    end
  end

  def test_call_noisy_if_rules_were_made
    add_hook(:noisy, proc {|s,r| raise NoisyError})
    config = config_mock
    config.reports[{:noisy => nil}] = :down

    assert_raise NoisyError do
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
    ScoutExample.class_eval do
      register_hook hook, callable
    end
  end
end
