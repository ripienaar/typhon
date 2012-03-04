class Typhon
  class Heads
    # these methods are here to help the DSL have somewhere to
    # store instances of the heads and some utilities to manage
    # them.  This is effectively a global named scope that just
    # holds blocks of codes
    class << self
      def register_head(name, files, head)
        @heads ||= {}

        [files].flatten.each do |file|
          @heads[file] ||= {}

          raise "Already have a head called #{name} for file #{file}" if @heads[file].include?(name)

          headklass = Head.new
          headklass.define_singleton_method(:call, head)

          @heads[file][name] = headklass

          Log.debug("Registered a new head: #{name} for file #{file}")
        end
      end

      def clear!
        Log.debug("Clearing previously loaded heads")
        @heads = {}
      end

      def heads
        @heads || {}
      end

      def files
        @heads.keys
      end
    end

    def initialize
      @dir = File.join(Config.configdir, "heads")
      @tails = {}
      @linecount = 0
      @starttime = Time.now
    end

    def log_stats
      uptime = seconds_to_human((Time.now - @starttime).to_i)

      Log.info("Up for #{uptime} read #{@linecount} lines")
    end

    # Handles a line of text from a log file by finding the
    # heads associated with that file and calling them all
    def feed(file, pos, text)
      return unless Heads.heads.include?(file)

      Heads.heads[file].each_pair do |name, head|
        begin
          head.call(file, pos, text)
          @linecount += 1
        rescue Exception => e
          Log.error("Failed to handle line from #{file}##{pos} with head #{name}: #{e.class}: #{e}")
        end
      end
    end

    # Loads/Reload all the heads from disk, a trigger file is used that
    # the user can touch the trigger and it will initiate a complete reload
    def loadheads
      if File.exist?(triggerfile)
        triggerage = File::Stat.new(triggerfile).mtime.to_f
      else
        triggerage = 0
      end

      @loaded ||= 0

      if (@loaded < triggerage) || @loaded == 0
        Heads.clear!
        headfiles.each do |head|
          loadhead(head)
        end
      end

      starttails

      @loaded = Time.now.to_f
    end

    # Start EM tailers for each known file.  If a file has become orphaned
    # by all its heads being removed then close the tail
    def starttails
      # for all the files that have interested heads start tailers
      Typhon.files.each do |file|
        unless @tails.include?(file)
          Log.debug("Starting a new tailer for #{file}")
          @tails[file] = EventMachine::file_tail(file) do |ft, line|
            self.feed(ft.path, ft.position, line)
          end
        end
      end

      # for all the tailers make sure there are files, else close the tailer
      @tails.keys.each do |file|
        unless Typhon.files.include?(file)
          Log.debug("Closing tailer for #{file} there are no heads attached")

          begin
            @tails[file].close
          rescue
          end
        end
      end
    end

    def loadhead(head)
      Log.debug("Loading head #{head}")
      load head
    rescue Exception => e
      puts "Failed to load #{head}: #{e.class}: #{e}"
      p e.backtrace
    end

    def headfiles
      if File.directory?(@dir)
        Dir.entries(@dir).grep(/head.rb$/).map do |f|
          File.join([@dir, f])
        end
      else
        raise "#{@dir} is not a directory"
      end
    end

    def triggerfile
      File.join([@dir, "reload.txt"])
    end

    # borrowed from ohai, thanks Adam.
    def seconds_to_human(seconds)
      days = seconds.to_i / 86400
      seconds -= 86400 * days

      hours = seconds.to_i / 3600
      seconds -= 3600 * hours

      minutes = seconds.to_i / 60
      seconds -= 60 * minutes

      if days > 1
        return sprintf("%d days %02d hours %02d minutes %02d seconds", days, hours, minutes, seconds)
      elsif days == 1
        return sprintf("%d day %02d hours %02d minutes %02d seconds", days, hours, minutes, seconds)
      elsif hours > 0
        return sprintf("%d hours %02d minutes %02d seconds", hours, minutes, seconds)
      elsif minutes > 0
        return sprintf("%d minutes %02d seconds", minutes, seconds)
      else
        return sprintf("%02d seconds", seconds)
      end
    end

  end
end
