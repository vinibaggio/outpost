require 'test_helper'

class OutpostReportTest < Test::Unit::TestCase

  def test_report_with_all_up
    assert_equal :up, Outpost::Report.summarize([:up, :up, :up, :up])
  end

  def test_report_with_mixed_status
    assert_equal :down, Outpost::Report.summarize([:up, :down, :up, :up])
  end

  def test_report_with_all_down
    assert_equal :down, Outpost::Report.summarize([:down, :down, :down])
  end

  def test_report_with_no_statuses
    assert_equal :down, Outpost::Report.summarize([])
  end

end
