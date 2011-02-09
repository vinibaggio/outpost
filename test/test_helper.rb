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
require 'support/stubs'
require 'support/nothing_raised'

require 'outpost'
require 'outpost/expectations'
require 'outpost/notifiers'
require 'outpost/scouts'

include Support::Stubs
include Support::NothingRaised

