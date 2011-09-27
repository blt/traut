Traut -- a real-time notification automaton
===========================================

It's not uncommon that an event will happen in a computer cluster for
which a system administrator is needed to execute a program or two: a
database goes down and it's time to switch to a hot-standby or there's
a vital configuration fix that needs to go out faster than the ususal
Puppet update interval. Maybe you have a specific human process that's
kicked off when a 5xx HTTP error gets recorded by your
httpd. Heretofore someone scans the logs periodically, though it could
be done by a machine. In fact, all of this could be done by a machine.

Traut is a program which listens to an AMQP queue and executes scripts
found in local `/usr/local/bin/traut/` based on the message route. It
is presumed that traut will be supported by a small legion of log
watchers, daemon prodders and otherwise. Here at CarePilot, we have a
daemon hooked up to Gerrit's ssh stream-events so that we might turn
'change-merged' events into immediate project deployments, for
example. See `samples/kili`. All payloads are delivered to the
scripts' stdin.

Traut cannot daemonize itself. We use [supervisord](http://supervisord.org/) to daemonize Traut;
the code needed to achieve self-daemonization is outside of the core
focus of this program.

Installation
------------

Traut is distributed through the RubyGems

    gem install traut

You're tasked with providing your own init scripts and configuration
files. See the contents of etc/ for an example traut.conf. Note that
`traut.conf.sample` defines a script `deploy/app` to be run in
response to `com.carepilot.event.code.review.app` events, making its
full path `/tmp/traut/scripts/deploy/app`.

Known Issues
------------

* traut has no ability to reload its configuration or restart. It must
  be killed and started.
* traut doesn't do log rotation. Run logrotate on your system.