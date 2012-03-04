class Typhon
  require 'rubygems'
  require 'yaml'
  require 'eventmachine'
  require 'eventmachine-tail'
  require 'typhon/heads'
  require 'typhon/log'
  require 'typhon/config'
  require 'typhon/stompclient'

  class << self
    def heads
      Heads.heads
    end

    def files
      Heads.heads.keys
    end

    def grow(options, &blk)
      raise "Heads need a name" unless options[:name]
      raise "Heads need files" unless options[:files]

      Heads.register_head(options[:name], options[:files], blk)
    end

    def stomp=(stomp)
      @stomp = stomp
    end

    def stomp
      @stomp
    end

    def daemonize
      fork do
        Process.setsid
        exit if fork
        Dir.chdir('/tmp')
        STDIN.reopen('/dev/null')
        STDOUT.reopen('/dev/null', 'a')
        STDERR.reopen('/dev/null', 'a')

        yield
      end
    end
  end

  attr_reader :heads

  def initialize(path="/etc/typhon")
    @configdir = path

    Config[:configdir] = path
    Config.loadconfig

    @heads = Heads.new
    @stomp = nil
  end

  def tail
    EM.run do
      @heads.loadheads

      if Config[:stomp]
        Log.debug("Connecting to Stomp Server %s:%d" % [ Config[:stomp][:server], Config[:stomp][:port] ])
        @stomp = EM.connect Config[:stomp][:server], Config[:stomp][:port], Typhon::StompClient, {:auto_reconnect => true, :timeout => 2}
        Typhon.stomp = @stomp
      end

      EM.add_periodic_timer(10) do
        @heads.loadheads
      end

      if Config[:stat_log_frequency] > 0
        EM.add_periodic_timer(Config[:stat_log_frequency]) do
          @heads.log_stats
        end
      end
    end
  end
end
