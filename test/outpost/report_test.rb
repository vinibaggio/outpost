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
end
