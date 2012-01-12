require 'fakeweb'

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:get, "http://localhost:9595", :body => 'Up and running!', :status => 200)
FakeWeb.register_uri(:get, "http://localhost:9595/fail", :body => 'Omg fail', :status => 500)
FakeWeb.register_uri(:get, "http://localhost:9595/warning", :body => 'Omg need payment', :status => 402)
