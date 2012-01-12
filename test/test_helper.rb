require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'ruby-debug' unless RUBY_VERSION > '1.9'
require 'ostruct'
require 'minitest/spec'
require 'minitest/autorun'

# Integration test helpers
require 'support/stubs'
require 'support/nothing_raised'

require 'outpost'
require 'outpost/expectations'
require 'outpost/notifiers'
require 'outpost/scouts'

include Support::Stubs
include Support::NothingRaised


#moveme to other file!

require 'fakeweb'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:get, "http://localhost:9595", :body => 'Up and running!', :status => 200)
FakeWeb.register_uri(:get, "http://localhost:9595/fail", :body => 'Omg fail', :status => 500)
FakeWeb.register_uri(:get, "http://localhost:9595/warning", :body => 'Omg need payment', :status => 402)
