require 'test_helper'

describe Outpost::Expectations::ResponseBody do
  class SubjectBody
    class << self
      attr_reader :expectation, :evaluation_method

      def expect(expectation, evaluation_method)
        @expectation       = expectation
        @evaluation_method = evaluation_method
      end

    end
    extend Outpost::Expectations::ResponseBody
  end

  describe ".evaluate_response_body with match" do
    it "should return true when it matches" do
      assert SubjectBody.evaluate_response_body(scout_stub, :match => /ll/)
    end

    it "should return false when it doesn't" do
      refute SubjectBody.evaluate_response_body(scout_stub, :match => /omg/)
    end
  end

  describe ".evaluate_response_body with not_match" do
    it "should return true when it matches" do
      assert SubjectBody.evaluate_response_body(scout_stub, :not_match => /omg/)
    end

    it "should return false when it doesn't" do
      refute SubjectBody.evaluate_response_body(scout_stub, :not_match => /Hello/)
    end
  end

  describe ".evaluate_response_body with equals" do
    it "should return true when it matches" do
      assert SubjectBody.evaluate_response_body(scout_stub, :equals => "Hello!")
    end

    it "should return false when it doesn't" do
      refute SubjectBody.evaluate_response_body(scout_stub, :equals => "Hell")
    end
  end

  describe ".evaluate_response_body with differs" do
    it "should return true when it matches" do
      assert SubjectBody.evaluate_response_body(scout_stub, :differs => "Hell")
    end

    it "should return false when it doesn't" do
      refute SubjectBody.evaluate_response_body(scout_stub, :differs => "Hello!")
    end
  end

  describe ".evaluate_response_body with multiple rules" do
    it "should return true when all rules matches" do
      rules = {:differs => 'omg', :match => /ll/}
      assert SubjectBody.evaluate_response_body(scout_stub, rules)
    end

    it "should return false when there are no matches" do
      rules = {:equals => 'omg', :not_match => /ll/}
      refute SubjectBody.evaluate_response_body(scout_stub, rules)
    end

    it "should return false when at least one rule doesn't match" do
      rules = {:equals => 'Hello!', :match => /Hell/, :differs => 'Hello!'}
      refute SubjectBody.evaluate_response_body(scout_stub, rules)
    end
  end

  it "should set expectation correctly" do
    assert_equal :response_body, SubjectBody.expectation
  end

  it "should set evaluation method correctly" do
    assert_equal SubjectBody.method(:evaluate_response_body), \
      SubjectBody.evaluation_method
  end

  private
  def scout_stub
    build_stub(:response_body => 'Hello!')
  end
end
