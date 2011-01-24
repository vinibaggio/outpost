require 'test_helper'

describe Outpost::ResponseBodyHook do
  class SubjectBody
    class << self
      attr_reader :hook, :evaluation_method

      def register_hook(hook, evaluation_method)
        @hook = hook
        @evaluation_method = evaluation_method
      end

    end
    extend Outpost::ResponseBodyHook
  end

  describe ".evaluate_response_body with match" do
    it "should return true when it matches" do
      assert SubjectBody.evaluate_response_body(scout_mock, :match => /ll/)
    end

    it "should return false when it doesn't" do
      refute SubjectBody.evaluate_response_body(scout_mock, :match => /omg/)
    end
  end

  describe ".evaluate_response_body with not_match" do
    it "should return true when it matches" do
      assert SubjectBody.evaluate_response_body(scout_mock, :not_match => /omg/)
    end

    it "should return false when it doesn't" do
      refute SubjectBody.evaluate_response_body(scout_mock, :not_match => /Hello/)
    end
  end

  describe ".evaluate_response_body with equals" do
    it "should return true when it matches" do
      assert SubjectBody.evaluate_response_body(scout_mock, :equals => "Hello!")
    end

    it "should return false when it doesn't" do
      refute SubjectBody.evaluate_response_body(scout_mock, :equals => "Hell")
    end
  end

  describe ".evaluate_response_body with differs" do
    it "should return true when it matches" do
      assert SubjectBody.evaluate_response_body(scout_mock, :differs => "Hell")
    end

    it "should return false when it doesn't" do
      refute SubjectBody.evaluate_response_body(scout_mock, :differs => "Hello!")
    end
  end

  describe ".evaluate_response_body with multiple rules" do
    it "should return true when all rules matches" do
      rules = {:differs => 'omg', :match => /ll/}
      assert SubjectBody.evaluate_response_body(scout_mock, rules)
    end

    it "should return false when there are no matches" do
      rules = {:equals => 'omg', :not_match => /ll/}
      refute SubjectBody.evaluate_response_body(scout_mock, rules)
    end

    it "should return false when at least one rule doesn't match" do
      rules = {:equals => 'Hello!', :match => /Hell/, :differs => 'Hello!'}
      refute SubjectBody.evaluate_response_body(scout_mock, rules)
    end
  end

  it "should set hook correctly" do
    assert_equal :response_body, SubjectBody.hook
  end

  it "should set evaluation method correctly" do
    assert_equal SubjectBody.method(:evaluate_response_body), \
      SubjectBody.evaluation_method
  end

  private
  def scout_mock
    @scout_mock ||= OpenStruct.new.tap do |scout_mock|
      scout_mock.response_body = 'Hello!'
    end
  end
end
