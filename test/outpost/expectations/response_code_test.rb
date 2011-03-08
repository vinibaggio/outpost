require 'test_helper'
require 'ostruct'

describe Outpost::Expectations::ResponseCode do
  class SubjectCode
    class << self
      attr_reader :expectation, :evaluation_method

      def expect(expectation, evaluation_method)
        @expectation       = expectation
        @evaluation_method = evaluation_method
      end

    end
    extend Outpost::Expectations::ResponseCode
  end

  it "should return true when response codes match" do
    assert SubjectCode.evaluate_response_code(scout_stub, 200)
  end

  it "should return false when response codes doesn't match" do
    refute SubjectCode.evaluate_response_code(scout_stub, 404)
  end

  it "should convert types accordinly" do
    assert SubjectCode.evaluate_response_code(scout_stub, "200")
  end

  it "should set expectation correctly" do
    assert_equal :response_code, SubjectCode.expectation
  end

  it "should set evaluation method correctly" do
    assert_equal SubjectCode.method(:evaluate_response_code),
      SubjectCode.evaluation_method
  end

  it "should return true when response code is included in the list" do
    assert SubjectCode.evaluate_response_code(scout_stub, [200, 301])
  end

  it "should refute when response code is not included in the list" do
    refute SubjectCode.evaluate_response_code(scout_stub, [500, 503])
  end

  private
  def scout_stub
    build_stub(:response_code => 200)
  end
end
