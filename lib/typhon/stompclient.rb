class Typhon
  class StompClient < EM::Connection
    include EM::Protocols::Stomp

    def initialize(params={})
      @connected = false
      @options = {:auto_reconnect => true, :timeout => 2, :max_queue_size => 500}
      @queue = EM::Queue.new
    end

    def connection_completed
      connect :login => Config[:stomp][:user], :passcode => Config[:stomp][:pass]

      Log.debug("Authenticated to %s:%d" % [ Config[:stomp][:server], Config[:stomp][:port] ])
      @connected = true
    end

    def unbind
      Log.error("Connection to %s:%d failed" % [ Config[:stomp][:server], Config[:stomp][:port] ])
      @connected = false

      EM.add_timer(@options[:timeout]) do
        Log.debug("Connecting to Stomp Server %s:%d" % [ Config[:stomp][:server], Config[:stomp][:port] ])
        reconnect Config[:stomp][:server], Config[:stomp][:port]
      end
    end

    def connected?
      (@connected && !error?)
    end

    def publish(topic, message, param={})
      if connected?
        send(topic, message, param)

        until @queue.empty? do
          @queue.pop do |msg|
            send(msg[:topic], msg[:message], msg[:param])
          end
        end
      else
        if @queue.size < @options[:max_queue_size]
          @queue.push({:topic => topic, :message => message, :param => param})
        end
      end
    end
  end
end

