require 'test_helper'

describe Outpost::Report do
  it "should report up when all are up" do
    assert_equal :up, Outpost::Report.summarize([:up, :up, :up, :up])
  end

  it "should report down when mixed statuses" do
    assert_equal :down, Outpost::Report.summarize([:up, :down, :up, :up])
  end

  it "should report down when all are down" do
    assert_equal :down, Outpost::Report.summarize([:down, :down, :down])
  end

  it "should report down when there are no statuses" do
    assert_equal :down, Outpost::Report.summarize([])
  end

  it "should report warning when all are warning" do
    assert_equal :warning, Outpost::Report.summarize([:warning, :warning])
  end

  it "should report warning when mixed up and warning" do
    assert_equal :warning, Outpost::Report.summarize([:warning, :up, :up])
  end

  it "should report down when mixed down and warning" do
    assert_equal :down, Outpost::Report.summarize([:warning, :down, :up])
  end
end
