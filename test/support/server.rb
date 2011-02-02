require 'rack/handler/thin'
require 'net/http'

class Server
  # Got it from Capybara, but simplified it a bit.
  # lib/capybara/server.rb
  def responsive?
    res = Net::HTTP.start('localhost', 9595) { |http| http.get('/') }

    res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
  rescue Errno::ECONNREFUSED, Errno::EBADF
    return false
  end

  def boot(app)
    if not responsive?
      Thread.new do
        Thin::Logging.silent = true
        Rack::Handler::Thin.run(app, :Port => 9595)
      end
    end
  end
end
