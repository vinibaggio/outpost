require 'test_helper'

require 'outpost/scouts/http_scout'

class BasicDSLTest < Test::Unit::TestCase
  class ExampleOne < Outpost::DSL
    depends Outpost::Scouts::HttpScout => 'master http server' do
      options :host => 'example.com'
      report :up, :response_code => 200
    end
  end

  def test_run_example
    assert_equal :up, ExampleOne.new.run
  end
end
