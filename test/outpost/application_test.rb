require 'test_helper'

describe Outpost::Application do
  class ScoutMock
    class << self
      attr_accessor :status
    end

    def initialize(*args); end
    def run              ; self.class.status ; end
    def report_data;     ; {} ; end
  end

  class NotifierMock
    class << self
      attr_accessor :last_messages
    end
    attr_accessor :options

    def initialize(options); @options = options; end

    def notify(outpost)
      self.class.last_messages = outpost.messages
    end
  end

  class ExampleOne < Outpost::Application
    notify NotifierMock, :email => 'mail@example.com'

    using ScoutMock => 'master http server' do
      options :host => 'localhost'
      report :up, :response_code => 200
    end
  end

  before(:each) do
    @scouts = ExampleOne.new.scouts
  end

  it "should create correct scout description" do
    assert_equal(ScoutMock, @scouts.first.first)
    assert_equal('master http server', @scouts.first.last[:description])
  end

  it "should create correct scout config" do
    config = @scouts.first.last[:config]
    assert_equal({:host => 'localhost'}, config.options)
    assert_equal({{:response_code => 200} => :up}, config.reports)
  end

  it "should create notifiers configuration" do
    notifiers = ExampleOne.new.notifiers
    assert_equal({NotifierMock => {:email => 'mail@example.com'}}, notifiers)
  end

  describe "#add_scout" do
    before(:each) do
      ScoutMock.status = :up
    end

    it "should be able to create scouts programatically" do
      outpost = create_outpost

      assert_equal :up, outpost.run
    end
  end

  describe "#add_notifier" do
    before(:each) do
      ScoutMock.status = :up
    end

    it "should be able to create notifications programatically" do
      outpost = create_outpost
      outpost.run
      outpost.notify

      assert_equal "ScoutMock: 'master http server' is reporting up.",
        NotifierMock.last_messages.first
    end
  end

  describe "#run" do
    it "should return up when scouts return up" do
      ScoutMock.status = :up
      assert_equal :up, ExampleOne.new.run
    end

    it "should return up when scouts return down" do
      ScoutMock.status = :down
      assert_equal :down, ExampleOne.new.run
    end
  end

  describe "#notify" do
    before(:each) do
      NotifierMock.last_messages = nil
    end

    it "should run the notifications if there are reports to deliver" do
      ScoutMock.status = :up

      outpost = ExampleOne.new
      outpost.run
      outpost.notify

      assert_equal "ScoutMock: 'master http server' is reporting up.",
        NotifierMock.last_messages.first
    end

    it "should not run the notifications if there are no reports" do
      ExampleOne.new.notify

      refute NotifierMock.last_messages
    end

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

  describe "#warning?" do
    before(:each) do
      @outpost = ExampleOne.new
    end

    it "should return true when last status is warning" do
      ScoutMock.status = :warning
      @outpost.run

      assert @outpost.warning?
    end

    it "should return false when last status isn't warning" do
      ScoutMock.status = :up
      @outpost.run

      refute @outpost.warning?
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

  describe "#name" do
    it "should be set as the class is informed" do
      ExampleTwo = Class.new(ExampleOne)
      ExampleTwo.class_eval do
        name 'Example outpost'
      end

      assert_equal 'Example outpost', ExampleTwo.new.name
    end

    it "should be the class' name if it is not set" do
      assert_equal 'ExampleOne', ExampleOne.new.name
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

  describe "#reports" do

  end

  private

  def create_outpost
    Outpost::Application.new.tap do |outpost|
      outpost.add_scout ScoutMock => 'master http server' do
        report :up, :response_code => 200
      end

      outpost.add_notifier NotifierMock, :email => 'mail@example.com'
    end
  end
end
