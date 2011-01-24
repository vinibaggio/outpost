# Outpost

Outpost is under development and is a project for the RMU: Ruby Mendicant
University.

## Features

Outpost is a tool to monitor the state of your service (not server). What does it mean?

It means:

* it can monitor the state of a server, such as MySQL;
* it can monitor some business rule to see if everything is running accordingly (such as cron jobs)
* it can monitor several servers
* it can monitor whatever you can code with Ruby

It will connect to the related machines (it won't have any proxies/programs running on the servers to
report data) and collect the data. The idea is to be completely uncoupled with the systems.
It should report a status per declared system.

The idea is to make a reliable framework for the Ruby developer to create his own monitoring rules.
So, summing it all up, Nagios in Ruby, much cooler!

## How it works

Consider the following example:

    class WebOutpostExample < Outpost::DSL
      depends WebScout => "web page" do
        options :host => 'localhost', :port => 3000
        report :up, :response_code => 200
        report :up, :response_time => {:less_than => 100}
      end
    end
    outpost = WebOutpostExample.new
    outpost.check!
    outpost.up? #=> false


## Outpost

Outpost is the description of the system and provides a DSL to do it. 
Check "How it works" section for an example, or check the [integration tests](https://github.com/vinibaggio/outpost/blob/master/test/integration/basic_dsl_test.rb)
for more.

## Scout

Scout are pure Ruby classes that will test your server. For instance, check the
HttpScout example below:

    module Outpost
      class HttpScout < Outpost::Scout
        extend Outpost::ResponseCodeHook
        extend Outpost::ResponseBodyHook

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

It must implement the #setup and #execute methods. The magic lies in the #execute
method, where you can implement any kind of logic to test whether your system is up
or not. You may also include hooks in order to process the output of your system.
For more information about hooks, check the section below.

## Hooks

Hooks are responsible to test the output of the system's test in order to check
the status. They are simply callable objects, i.e., objects that respond to #call
and return true if any of the rules match.

So you can easily create your own hook. Let's recreate the ResponseCodeHook in
the HttpScout:

    module Outpost
      class HttpScout < Outpost::Scout
        register_hook :response_code, { |scout,code| scout.response_code == code }

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

You can also check the supplied hooks in the source of the project to have
an idea on how to implement more complex rules.

## TODO

There's a lot to be done yet. For example, SSH support, ResponseTime hooks,
support for :warning status, and multiple systems per Outpost.

## License

MIT.
