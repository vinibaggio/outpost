require 'test_helper'

class DSLTest < Test::Unit::TestCase
  class ExampleOne < Outpost::DSL
    depends Object => 'master http server' do
      options :host => 'localhost'
      report :up, :response_code => 200
    end
  end

  def setup
    @scouts = ExampleOne.scouts
  end

  def test_should_create_correct_scout_description
    assert_equal(Object, @scouts.keys.first)
    assert_equal('master http server', @scouts[Object][:description])

  end

  def test_should_create_correct_scout_config
    config = @scouts[Object][:config]
    assert_equal({:host => 'localhost'}, config.options)
    assert_equal({{:response_code => 200} => :up}, config.reports)
  end
end
