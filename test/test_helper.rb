require 'bundler'
Bundler.setup(:test)

require 'minitest/spec'

# Integration test helpers
require 'support/test_app'
require 'support/server'

require 'outpost'
require 'outpost/response_code_hook'
require 'outpost/response_body_hook'

# Inspired by assert_raises from minitest
def assert_nothing_raised(&block)
  block.call
rescue Exception => e
  flunk "No exception expected, but #{mu_pp(e.class)} was raised."
end

# Run example server throughout the test
@server = Server.new
@server.boot(TestApp)
