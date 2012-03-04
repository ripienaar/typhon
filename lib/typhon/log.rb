class Typhon
  class Log
    require 'syslog'

    include Syslog::Constants

    @configured = false

    @known_levels = [:debug, :info, :warn, :error, :fatal]

    class << self
      def log(msg, severity=:debug)
        configure unless @configured

        if @known_levels.index(severity) >= @known_levels.index(@active_level)
          Syslog.send(valid_levels[severity.to_sym], "#{from} #{msg}")
        end
      rescue Exception => e
        STDERR.puts("Failed to log: #{e.class}: #{e}: original log message: #{severity}: #{msg}")
        STDERR.puts(e.backtrace.join("\n\t"))
      end

      def configure
        Syslog.close if Syslog.opened?
        Syslog.open(File.basename($0))

        @active_level = Config[:loglevel]

        raise "Unknown log level #{@active_level} specified" unless valid_levels.include?(@active_level)

        @configured = true
      end

      # figures out the filename that called us
      def from
        from = File.basename(caller[4])
      end

      def valid_levels
        {:info  => :info,
         :warn  => :warning,
         :debug => :debug,
         :fatal => :crit,
         :error => :err}
      end

      def method_missing(level, *args, &block)
        super unless [:info, :warn, :debug, :fatal, :error].include?(level)

        log(args[0], level)
      end
    end
  end
end

