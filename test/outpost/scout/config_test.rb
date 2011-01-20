require 'test_helper'

class ConfigTest < Test::Unit::TestCase
  def setup
    @config = Outpost::Scout::Config.new
  end

  def test_assign_options
    @config.options :host => 'localhost'

    assert_equal({:host => 'localhost'}, @config.options)
  end

  def test_assign_report
    @config.report :up, :response_code => 200

    assert_equal({{:response_code => 200} => :up}, @config.reports)
  end

  def test_assign_multiple_reports
    @config.report :up, :response_code => 200
    @config.report :down, :response_code => 404

    assert_equal({
        {:response_code => 200} => :up,
        {:response_code => 404} => :down,
      }, @config.reports)
  end
end
