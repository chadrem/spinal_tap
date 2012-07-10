# SpinalTap

Spinal tap lets you easily connect into running ruby processes such as
daemons and cron scripts.  With great power comes great responsibility.

## Installation

Add this line to your application's Gemfile:

    gem 'spinal_tap'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spinal_tap

## Basic Usage

Start spinal when your long running process starts up:

    SpinalTap.start

By default it will listen for TCP connections on 127.0.0.1:9000.
You should be able to telnet into your process and type 'help' to view the default list of commands.
Spinal Tap uses threads so that it runs in the background of your application.

SpinalTap.start accepts the following options:

    :host => The address to listen on (default: 127.0.0.1).
    :port => The port to listen on (default: 9000).

You can stop the spinal tap server at any time:

    SpinalTap.stop

# Contributing to Spinal Tap:

1. Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
2. Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
3. Fork the project.
4. Start a feature/bugfix branch.
5. Commit and push until you are happy with your contribution.
6. Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
7. Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.
8. Create a new Pull Request.
