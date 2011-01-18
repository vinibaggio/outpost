h1. Project: Outpost


h2. Features

Outpost will be a tool to monitor the state of your service (not server). What does it mean?

It means:

* it can monitor the state of a server, such as MySQL;
* it can monitor some business rule to see if everything is running accordingly (such as cron jobs)
* it can monitor several servers
* it can monitor whatever you can code with Ruby

It will connect to the related machines (it won't have any proxies/stuff running on the servers to
report data) and collect the data. The idea is to be completely uncoupled with the systems.
It should report a status per declared system.

The idea is to make a reliable framework for the Ruby developer to create his own monitoring rules.
So, summing it all up, Nagios in Ruby!

h2. How it will work

Consider the following example:

<pre>
class WebOutpostExample < Outpost
  depends WebScout => "web page" do
    options :host => 'localhost', :port => 3000
    report :up, :response_code => 200
    report :up, :response_time => {:less_than => 100}
  end
end
outpost = WebOutpostExample.new
outpost.check!
outpost.up? #=> false
</pre>


* Outposts: describes your whole system, provides a DSL to describe your services
* Scouts: pure ruby stuff that will poke the service and check what it spits out
* Hooks: pre-made hooks will be available to check common stuff like response_code and response_time
