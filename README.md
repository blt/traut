Traut -- a cron-like for AMQP
=============================

Unix cron's an ancient program that runs a script dependent on the passage
time. Traut's the same way, except it keys off AMQP events instead. Use it to
update your Puppet machines or log-rotate if nagios sends a disk-full
warning. Significant number of possibilities.

Traut cannot daemonize itself. Use [supervisord](http://supervisord.org/) or
similar to daemonize Traut; the code needed to achieve self-daemonization is
outside of the core focus of this program.

Installation
------------

Traut is distributed through the RubyGems

    gem install traut

You're tasked with providing your own init scripts and configuration
files. See the contents of etc/ for an example traut.conf. Note that
`traut.conf.sample` defines a script `deploy/app` to be run in
response to `com.carepilot.event.code.review.app` events, making its
full path `/tmp/traut/scripts/deploy/app`.

Configuration
-------------

The source distribution has an [etc/](etc/) directory with example
configuration.

Use
---

Run traut from the root of the project like this:

    bundle exec bin/traut -C etc/traut.conf

Now, using [hare](https://github.com/blt/hare):

    $ hare --exchange_name traut --exchange_type topic --route_key whatthesum
    --producer "that wasn't so bad"

You should see nothing. Open up another terminal and

    $ hare --exchange_name traut --exchange_type topic --route_key 'whatthesum.exited'

Note that the route key is the same as before, save that '.exited' has been
appended to it. Listen to this channel if you need notification of
success. Run both hare commands in the order presented, notice the second print
a json hash.

See the sample configuration file for more details.
