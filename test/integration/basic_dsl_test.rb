require 'test_helper'

require 'outpost/scouts/http_scout'

class BasicDSLTest < Test::Unit::TestCase
  class ExampleSuccess < Outpost::DSL
    depends Outpost::Scouts::HttpScout => 'master http server' do
      options :host => 'example.com'
      report :up, :response_code => 200
    end
  end

  class ExampleFailure < Outpost::DSL
    depends Outpost::Scouts::HttpScout => 'master http server' do
      # Google will return 301, so it will fail
      options :host => 'google.com'
      report :up, :response_code => 200
    end
  end

  def test_run_success
    assert_equal :up, ExampleSuccess.new.run
  end

  def test_run_failure
    assert_equal :down, ExampleFailure.new.run
  end
end
