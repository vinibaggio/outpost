require 'test_helper'
require 'ostruct'

class ScoutTest < Test::Unit::TestCase
  class ScoutExample < Outpost::Scout
    attr_accessor :response
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

  private
  def config_mock
    OpenStruct.new.tap do |config|
      config.reports = {}
      config.reports[{:response => true}] = :up
      config.reports[{:response => false}] = :down
    end
  end
end
