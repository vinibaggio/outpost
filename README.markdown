# Outpost

Build status: [![Build Status](https://secure.travis-ci.org/vinibaggio/outpost.png)](http://travis-ci.org/vinibaggio/outpost)

## Features

Outpost is a tool to monitor the state of your service (not server). What does it mean?

It means:

* it can monitor the state of a server, such as MySQL;
* it can monitor some business rule to see if everything is running accordingly (such as cron jobs)
* it can monitor several servers
* it can monitor whatever you can code with Ruby

It will connect to the related machines (it won't have any proxies/agents running on the servers to
report data) and collect the data. The idea is to be completely uncoupled with the systems.
It should report a status per declared system.

The idea is to make a reliable framework for the Ruby developer to create his own monitoring rules.
So, summing it all up, Nagios in Ruby, much cooler!

## Information and examples

* [Rdoc](http://rdoc.info/github/vinibaggio/outpost/master/frames)
* [outpost-web](http://github.com/vinibaggio/outpost-web)

## Installing

Outpost is tested with Ruby 1.8.7 and Ruby 1.9.2.

    gem install outpost

## Starting

To create your Outposts, you must require 'outpost'. You also need to include
'outpost/scouts' if you want to use the supplied scouts. Example:

    require 'outpost'
    require 'outpost/scouts'

    class Monitor < Outpost::Application
      using Outpost::Scouts::Http => "web page" do
        options :host => 'localhost', :port => 3000
        report :up, :response_code => 200
      end
    end

    monitor = Monitor.new
    monitor.run
    p monitor.messages # => ["Outpost::Scouts::Http: 'web page' is reporting up."]


## How it works

Consider the following example:

    require 'outpost'
    require 'outpost/scouts'

    class HttpOutpostExample < Outpost::Application
      using Outpost::Scouts::Http => "web page" do
        options :host => 'localhost', :port => 3000
        report :up, :response_code => 200
        report :down, :response_body => {:match => /Ops/}
      end
    end
    outpost = HttpOutpostExample.new
    outpost.run # => :down

In this simple example, an Outpost was created to monitor a web server running
on localhost at port 3000. Every time #run is called, the outpost will
run associated rules (in this example, check if the HTTP response code is 200
and report "up" if it does and also check if the response body matches /Ops/,
reporting "down" in that case).

## Outpost

Outpost is the description of the system and provides a DSL to do it.
Check "How it works" section for an example, or check the [integration tests](https://github.com/vinibaggio/outpost/blob/master/test/integration/basic_application_test.rb)
for more.

## Scout

Scout are pure Ruby classes that will test your server. For instance, check the
Outpost::Scouts::Http example below:

    module Outpost
      module Scouts
        class Http < Outpost::Scout
          extend Outpost::Expectations::ResponseCode
          extend Outpost::Expectations::ResponseBody

          attr_reader :response_code, :response_body

          def setup(options)
            @host = options[:host]
            @port = options[:port] || 80
            @path = options[:path] || '/'
          end

          def execute
            response = Net::HTTP.get_response(@host, @path, @port)
            @response_code = response.code.to_i
            @response_body = response.body
          end
        end
      end
    end

It must implement the #setup and #execute methods. The magic lies in the #execute
method, where you can implement any kind of logic to test whether your system is up
or not. You may also include expectations in order to process the output of your system.
For more information about expectations, check the section below.

If you're interested in the data the Scouts got through a measurement, you can
tell Outpost that it must save that data after the measurement is run. That way
you can inquiry it for further analysis. This way, you can have Scouts without
any expectations/reports, so you can collect data without telling if the system
is either up or down. You can check an usage example in the [Reports
integration
test](https://github.com/vinibaggio/outpost/blob/master/test/integration/reporting_test.rb).

## Expectations

Consider the following code snippet, taken from previous examples:

    report :up, :response_code => 200
    report :down, :response_body => {:match => /Ops/}

In the example above, :response\_code and :response\_body are expectations, responsible
to get Scout's output and evaluate it, in order to determine a status.

They must be registered into each Scout that wish to support different types
of expectations. You can supply a block or an object that respond to #call
and return true if any of the rules match. It will receive an instance
of the scout (so you can query current system state) as the first parameter
and the state defined in the #report method as the second.

So you can easily create your own expectation. Let's recreate the :response\_code in
 Outpost::Scouts::Http:

    module Outpost
      module Scouts
        class Http < Outpost::Scout
          expect(:response_code) { |scout,code| scout.response_code == code }

          attr_reader :response_code

          def setup(options)
            @host = options[:host]
            @port = options[:port] || 80
            @path = options[:path] || '/'
          end

          def execute
            response = Net::HTTP.get_response(@host, @path, @port)
            @response_code = response.code.to_i
          end
        end
      end
    end

You can also check the supplied expectations in the source of the project to have
an idea on how to implement more complex rules.

## Notifiers

Notifiers query Outposts and act upon its status and reports. In the example
below, an Email notifier is being used to report failures in the system to the
system administrator:

    require 'outpost'
    require 'outpost/scouts'
    require 'outpost/notifiers'

    class HttpOutpostExample < Outpost::Application
      notify Outpost::Notifiers::Email, {
        :from => 'outpost@example.com',
        :to   => 'sleep_deprived_admin@example.com'
      }

      using Outpost::Scouts::Http => "web page" do
        options :host => 'localhost', :port => 3000
        report :up, :response_code => 200
        report :down, :response_body => {:match => /Ops/}
      end
    end
    outpost = HttpOutpostExample.new
    outpost.run # => :down

    # Will send an email to the poor sleep-deprived Sys Admin if the system is
    # down.
    outpost.notify if outpost.down?

## Creating Outpost applications programatically

It is also possible to create Outposts without having to subclass it. Use the
methods #add_scout and #add_notifier and you're set:

    outpost = Outpost::Application.new

    outpost.add_scout Outpost::Scouts::Http => 'master http server' do
      options :host => 'localhost', :port => 9595
      report :up, :response_code => 200
    end

    outpost.run

This is good when you want to have some sort of template (by inheriting from
Outpost::Application) and then configure things as you go.

## TODO

See [TODO](https://github.com/vinibaggio/outpost/blob/master/TODO.md).

## License

MIT License.
