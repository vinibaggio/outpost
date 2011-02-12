require 'test_helper'

require 'outpost/scouts'
require 'outpost/notifiers'

describe "using notifiers" do
  class ExampleMailNotifier < Outpost::Application
    notify Outpost::Notifiers::Email, {
      :from    => 'outpost@example.com',
      :to      => 'sleep_deprived_admin@example.com',
      :subject => 'System 1 status'
    }

    using Outpost::Scouts::Ping => 'load balancer' do
      options :host => 'localhost'
      report :down, :response_time => {:more_than => 0}
    end
  end

  before(:each) do
    Mail.defaults do
      delivery_method :test
    end

    @outpost = ExampleMailNotifier.new
    @outpost.run
  end

  after(:each) do
    Mail::TestMailer.deliveries = []
  end

  it "should send email when asked to notify" do
    @outpost.notify

    refute_empty Mail::TestMailer.deliveries
  end

  it "should set email headers accordingly" do
    @outpost.notify
    message = Mail::TestMailer.deliveries.first

    assert_equal 'outpost@example.com',              message.from.first.to_s
    assert_equal 'sleep_deprived_admin@example.com', message.to.first.to_s
    assert_equal 'System 1 status',                  message.subject.to_s
  end

  it "should not send email when not asked to notify" do
    assert_empty Mail::TestMailer.deliveries
  end
end
