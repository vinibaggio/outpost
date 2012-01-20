require 'test_helper'

require 'outpost/scouts'

describe "using only report data integration test" do
  class RetrieveServerData < Outpost::Application
    using Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595, :path => '/'
    end

    using Outpost::Scouts::Ping => :load_balancer do
      options :host => 'localhost'
      report :up, :response_time => {:less_than => 500}
    end
  end

  before(:each) do
    @outpost = RetrieveServerData.new
    @outpost.run
  end

  it "should build report for each scout" do
    assert_equal 2, @outpost.reports.size
  end

  it "should build reports with data" do
    http_report = @outpost.reports['master http server']
    ping_report = @outpost.reports[:load_balancer]

    report_data = http_report.data

    assert report_data.delete(:response_time) < 500
    assert_equal({:response_code => 200,
                  :response_body => 'Up and running!'}, http_report.data)
  end
end
