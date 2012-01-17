require 'test_helper'

describe Outpost::Notifiers::Email do
  before(:each) do
    Mail.defaults do
      delivery_method :test
    end
  end

  after(:each) do
    Mail::TestMailer.deliveries = []
  end

  describe "#initialize" do
    it "should raise error when :from is not present" do
      assert_raises ArgumentError do
        Outpost::Notifiers::Email.new(:to => 'mail@example.com')
      end
    end

    it "should raise error when :to is not present" do
      assert_raises ArgumentError do
        Outpost::Notifiers::Email.new(:from => 'mail@example.com')
      end
    end

    it "should not raise error when both :from and :to are supplied" do
      assert_nothing_raised do
        Outpost::Notifiers::Email.new(
          :from => 'mail@example.com',
          :to   => 'mailer@example.com'
        )
      end
    end

    it "should not be destructive" do
      options = {:from => 'mail@example.com', :to => 'mailer@example.com'}
      Outpost::Notifiers::Email.new(options)
      refute_empty options.keys
    end
  end

  describe "#delivery_method" do
    it "should use other delivery method if present" do
      subject = Outpost::Notifiers::Email.new(
          :from => 'mail@localhost',
          :to   => 'mailer@example.com',
          #using file_delivery send method for testing
          :delivery_method => [:file, {:location => Dir.tmpdir}]
        )

      subject.notify(outpost_stub)

      assert_equal Mail::TestMailer.deliveries, []
    end

    it "should use default if not present" do
      subject = Outpost::Notifiers::Email.new(
          :from => 'mail@example.com',
          :to   => 'mailer@example.com'
        )

      subject.notify(outpost_stub)

      assert_equal ["mail@example.com"], Mail::TestMailer.deliveries.first.from
    end    
  end

  describe "#notify" do
    it "should send a simple email" do
      subject = Outpost::Notifiers::Email.new(
        :from => 'mail@example.com',
        :to   => 'mailer@example.com'
      )

      subject.notify(outpost_stub)

      message = Mail::TestMailer.deliveries.first

      assert_equal ["mail@example.com"], message.from
      assert_equal ["mailer@example.com"], message.to
      assert_equal "Outpost notification", message.subject
      report = "This is the report for test outpost: System is UP!\n\n1\n2"
      assert_equal report, message.body.to_s
    end

    it "should be able to customize subject" do
      subject = Outpost::Notifiers::Email.new(
        :from    => 'mail@example.com',
        :to      => 'mailer@example.com',
        :subject => 'OMG'
      )

      subject.notify(outpost_stub)

      message = Mail::TestMailer.deliveries.first

      assert_equal ["mail@example.com"], message.from
      assert_equal ["mailer@example.com"], message.to
      assert_equal "OMG", message.subject
      report = "This is the report for test outpost: System is UP!\n\n1\n2"
      assert_equal report, message.body.to_s
    end
  end

  private

  def outpost_stub
    build_stub(
      :name        => 'test outpost',
      :last_status => :up,
      :messages    => ['1', '2']
    )
  end
end

