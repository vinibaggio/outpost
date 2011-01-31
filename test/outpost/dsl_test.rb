require 'test_helper'

describe Outpost::DSL do
  class ScoutMock
    class << self
      attr_accessor :status
    end
    def run; self.class.status; end
  end

  class ExampleOne < Outpost::DSL
    using ScoutMock => 'master http server' do
      options :host => 'localhost'
      report :up, :response_code => 200
    end
  end

  before(:each) do
    @scouts = ExampleOne.scouts
  end

  it "should create correct scout description" do
    assert_equal(ScoutMock, @scouts.keys.first)
    assert_equal('master http server', @scouts[ScoutMock][:description])
  end

  it "should create correct scout config" do
    config = @scouts[ScoutMock][:config]
    assert_equal({:host => 'localhost'}, config.options)
    assert_equal({{:response_code => 200} => :up}, config.reports)
  end

  describe "#up?" do
    before(:each) do
      @outpost = ExampleOne.new
    end

    it "should return true when last status is up" do
      ScoutMock.status = :up
      @outpost.run

      assert @outpost.up?
    end

    it "should return false when last status isn't up" do
      ScoutMock.status = :down
      @outpost.run

      refute @outpost.up?
    end
  end

  describe "#down?" do
    before(:each) do
      @outpost = ExampleOne.new
    end

    it "should return true when last status is down" do
      ScoutMock.status = :down
      @outpost.run

      assert @outpost.down?
    end

    it "should return false when last status isn't down" do
      ScoutMock.status = :up
      @outpost.run

      refute @outpost.down?
    end
  end

  describe "#messages" do
    before(:each) do
      @outpost = ExampleOne.new
    end

    it "should return true when last status is up" do
      ScoutMock.status = :up
      @outpost.run

      assert_equal "ScoutMock: 'master http server' is reporting up.",
        @outpost.messages.first
    end
  end
end
