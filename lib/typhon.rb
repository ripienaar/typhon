class Typhon
    require 'rubygems'
    require 'eventmachine'
    require 'eventmachine-tail'
    require 'typhon/heads'
    require 'typhon/log'
    require 'typhon/config'

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
    end

    def tail
        EM.run do
            @heads.loadheads

            EM.add_periodic_timer(10) do
                @heads.loadheads
            end
        end
    end
end
