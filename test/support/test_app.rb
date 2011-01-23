require 'sinatra/base'

class TestApp < Sinatra::Base
  get '/' do
    [200, 'Up and running!']
  end

  get '/fail' do
    [500, 'Omg fail']
  end
end
