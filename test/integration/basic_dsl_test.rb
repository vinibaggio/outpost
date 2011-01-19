require 'test_helper'

class BasicDSLTest < Test::Unit::TestCase
  class ExampleOne < Outpost::DSL
    depends Object => 'master http server' do
      options :host => 'localhost'
      report :up, :response_code => 200
    end
  end

  def test_run_example
    assert_equal :up, ExampleOne.new.run
  end
end
