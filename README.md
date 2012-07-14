# Spinal Tap

Spinal Tap lets you easily connect to running Ruby processes such as daemons and cron scripts.
Once connected, you can execute arbitrary commands inside of your process.

## Installation

Add this line to your application's Gemfile:

    gem 'spinal_tap'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spinal_tap

## Basic Usage

Start spinal at the beginning of your long running process:

    SpinalTap.start

By default it will listen for TCP connections on 127.0.0.1:9000.
You can then telnet into your process and type 'help' to view the default list of commands.
Currently, 'eval' is the main command you will use.
For example, you can execute code such as 'eval 5 + 5' and it will return 10.
The command set is limited, but in the future I will make it easy to add your own commands.
For now you'll have to make your own helper class and execute the methods via 'eval'.
Spinal Tap uses threads to run in the background of your process, but aware that you have full access to your processes's memory via 'eval'.

SpinalTap.start accepts the following options:

    :host => The address to listen on (default: 127.0.0.1).
    :port => The port to listen on (default: 9000).

You can stop the spinal tap server at any time:

    SpinalTap.stop

## Security

With great power comes great responsibility.
Currently no authentication exists so anyone who can connect to Spinal Tap has complete control over your process.
This includes changing memory, reloading classes, killing the process, and pretty much any other nasty thing you can do with Ruby's 'eval' method.
Use at your own risk!  You have been warned!

# Contributing to Spinal Tap:

1. Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
2. Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
3. Fork the project.
4. Start a feature/bugfix branch.
5. Commit and push until you are happy with your contribution.
6. Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
7. Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
8. Create a new Pull Request.
