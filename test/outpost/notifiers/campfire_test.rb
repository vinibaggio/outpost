require 'test_helper'

describe Outpost::Notifiers::Campfire do
  class CampfireMock
    class << self
      attr_accessor :mock
    end
    def initialize(*args);                        end
    def find_room_by_name(room); self.class.mock; end
  end

  describe "#initialize" do
    it "should raise argument error if token is missing" do
      params = {:subdomain => '123', :room => '123'}

      assert_raises ArgumentError do
        campfire = Outpost::Notifiers::Campfire.new(params)
      end
    end

    it "should raise argument error if subdomain is missing" do
      params = {:token => '123', :room => '123'}

      assert_raises ArgumentError do
        campfire = Outpost::Notifiers::Campfire.new(params)
      end
    end

    it "should raise argument error if room is missing" do
      params = {:token => '123', :subdomain => '123'}

      assert_raises ArgumentError do
        campfire = Outpost::Notifiers::Campfire.new(params)
      end
    end

    it "should raise argument error if no attributes were supplied" do
      assert_raises ArgumentError do
        campfire = Outpost::Notifiers::Campfire.new
      end
    end
  end

  describe "#notify" do
    it "should build the message" do
      campfire_room_mock = MiniTest::Mock.new
      campfire_room_mock.expect :speak, nil, ["System is up: 1,2"]

      CampfireMock.mock = campfire_room_mock

      params = {:token => '123', :subdomain => '123', :room => '123'}
      campfire = Outpost::Notifiers::Campfire.new(params)
      campfire.notify(outpost_stub, CampfireMock)

      campfire_room_mock.verify
    end
  end

  def outpost_stub
    build_stub(
      :name        => 'test outpost',
      :last_status => :up,
      :messages    => ['1', '2']
    )
  end

  def build_stub(params={})
    OpenStruct.new.tap do |stub|
      params.each do |key, val|
        stub.send "#{key}=", val
      end
    end
  end
end
