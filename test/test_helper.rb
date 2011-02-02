require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'ruby-debug'
require 'ostruct'
require 'minitest/spec'
require 'minitest/autorun'

# Integration test helpers
require 'support/test_app'
require 'support/server'

require 'outpost'
require 'outpost/expectations'
require 'outpost/scouts'

# Inspired by assert_raises from minitest
def assert_nothing_raised(&block)
  block.call
rescue Exception => e
  flunk "No exception expected, but #{mu_pp(e.class)} was raised."
end

