require 'test_helper'

require 'outpost/scouts/http'
require 'outpost/notifiers/email'

describe "creating outpost apps without subclassing" do
  before(:each) do
    @server = Server.new
    @server.boot(TestApp)
    @server.wait_until_booted

    Mail.defaults do
      delivery_method :test
    end
  end

  after(:each) do
    Mail::TestMailer.deliveries = []
  end

  it "should report up when everything's ok" do
    assert_equal :up, outpost.run
  end

  it "should notify up when everything's ok" do
    outpost.add_notifier Outpost::Notifiers::Email, {
      :from    => 'outpost@example.com',
      :to      => 'sleep_deprived_admin@example.com',
      :subject => 'System 1 status'
    }

    outpost.run
    outpost.notify

    refute_empty Mail::TestMailer.deliveries
  end

  it "should not notify when there are no notifiers" do
    outpost.run

    assert_empty Mail::TestMailer.deliveries
  end

  private

  def outpost
    @outpost ||= Outpost::Application.new.tap do |outpost|
      outpost.add_scout Outpost::Scouts::Http => 'master http server' do
        options :host => 'localhost', :port => 9595
        report :up, :response_code => 200
      end
    end
  end
end
