require 'test_helper'
require 'ostruct'

describe Outpost::ResponseCodeHook do
  class SubjectCode
    class << self
      attr_reader :hook, :evaluation_method

      def register_hook(hook, evaluation_method)
        @hook = hook
        @evaluation_method = evaluation_method
      end

    end
    extend Outpost::ResponseCodeHook
  end

  it "should return true when response codes match" do
    assert SubjectCode.evaluate_response_code(scout_mock, 200)
  end

  it "should return false when response codes doesn't match" do
    refute SubjectCode.evaluate_response_code(scout_mock, 404)
  end

  it "should convert types accordinly" do
    assert SubjectCode.evaluate_response_code(scout_mock, "200")
  end

  it "should set hook correctly" do
    assert_equal :response_code, SubjectCode.hook
  end

  it "should set evaluation method correctly" do
    assert_equal SubjectCode.method(:evaluate_response_code), \
      SubjectCode.evaluation_method
  end

  private
  def scout_mock
    @scout_mock ||= OpenStruct.new.tap do |scout_mock|
      scout_mock.response_code = 200
    end
  end
end
