require 'test_helper'

class OutpostReportTest < Test::Unit::TestCase

  def test_report_with_all_up
    assert_equal :up, Outpost::Report.sumarize([:up, :up, :up, :up])
  end

  def test_report_with_mixed_status
    assert_equal :down, Outpost::Report.sumarize([:up, :down, :up, :up])
  end

  def test_report_with_all_down
    assert_equal :down, Outpost::Report.sumarize([:down, :down, :down])
  end

end
