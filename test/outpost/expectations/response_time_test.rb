require 'test_helper'

describe Outpost::Expectations::ResponseTime do
  class SubjectTime
    class << self
      attr_reader :expectation, :evaluation_method

      def expect(expectation, evaluation_method)
        @expectation       = expectation
        @evaluation_method = evaluation_method
      end

    end
    extend Outpost::Expectations::ResponseTime
  end

  describe ".evaluate_response_time with less_than" do
    it "should return true when it matches" do
      assert SubjectTime.evaluate_response_time(scout_stub, :less_than => 5000)
    end

    it "should return false when it doesn't" do
      refute SubjectTime.evaluate_response_time(scout_stub, :less_than => 1)
    end
  end

  describe ".evaluate_response_time with more_than" do
    it "should return true when it matches" do
      assert SubjectTime.evaluate_response_time(scout_stub, :more_than => 1)
    end

    it "should return false when it doesn't" do
      refute SubjectTime.evaluate_response_time(scout_stub, :more_than => 5000)
    end
  end

  describe ".evaluate_response_time with multiple rules" do
    it "should return true when all rules matches" do
      rules = {:more_than => 200, :less_than => 5000}
      assert SubjectTime.evaluate_response_time(scout_stub, rules)
    end

    it "should return false when there are no matches" do
      rules = {:more_than => 700, :less_than => 200}
      refute SubjectTime.evaluate_response_time(scout_stub, rules)
    end

    it "should return false when at least one rule doesn't match" do
      rules = {:more_than => 100, :less_than => 200}
      refute SubjectTime.evaluate_response_time(scout_stub, rules)
    end
  end

  it "should set expectation correctly" do
    assert_equal :response_time, SubjectTime.expectation
  end

  it "should set evaluation method correctly" do
    assert_equal SubjectTime.method(:evaluate_response_time),
      SubjectTime.evaluation_method
  end

  private
  def scout_stub
    build_stub(:response_time => 300)
  end
end

