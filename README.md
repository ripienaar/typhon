What?
=====

A little container that lets you write blocks to process multiple files being tailed.

It uses eventmachine-tail to do the hard work, it really is just some sugar to make
things a bit more pleasant.

By putting the following in _bob`_`head.rb_:
<pre>
Typhon.grow(:name => "bob", :files => "/var/log/mcollective.log") do |file, pos, line|
    puts "bob ate #{line}"
end
</pre>

You will simply get a line of text for each line that appears in the log file.

You can define many heads as you like, and multiple heads per file.  Heads go into
_/etc/typhon/heads_ in files matching _*`_`head.rb_, you can just touch a file called
_reload.txt_ in that directory to cause all the heads to be re-read from disk

It will check every 10 seconds if this _reload.txt_ has changed and initiate a reload
of all the heads, any files that are new will be tailed and any files being tailed with
no more heads attached will be closed.

Configuration?
--------------

By default it logs to syslog at info level you can change this in the config file
_/etc/typhon/typhon.yaml_:

    ---
    :loglevel: :debug
    :stat_log_frequency: 3600

It will log some stats about uptime and lines processed, in this case that will happen
every 3600 seconds

Stomp Connection?
-----------------

My main use will be to process logs and emit events over middleware.  We include an
instance of the EventMachine stomp connection that can be started.  To configure this
add to the config file:

    ---
    :loglevel: :debug
    :stomp:
       :user: typhon
       :pass: secret
       :server: localhost
       :port: 6163

With this in place you can publish messages to the middleware:

    class Typhon
        grow(:name => "jack", :files => "/var/log/foo.log") do |file, pos, line|
            stomp.publish("/topic/foo", line)
        end
    end

Should the connection fail it will be retried every 2 seconds, messages that are
published while the connection is down are queued and sent soon as the connection
comes up.  The queue can hold 500 messages, soon as it's full it will overflow and
messages will be discarded

The Name?
---------
Typhon is a mythical beast:

<pre>
He appeared man-shaped down to the thighs, with two coiled vipers in place of legs.
Attached to his hands in place of fingers were a hundred serpent heads, fifty per hand.
</pre>

Each bit of Typhon logic goes in a head.

Who?
----

R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net
