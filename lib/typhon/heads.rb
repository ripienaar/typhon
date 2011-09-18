class Typhon
    class Heads
        class << self
            def register_head(name, files, head)
                @heads ||= {}

                [files].flatten.each do |file|
                    @heads[file] ||= {}

                    raise "Already have a head called #{name} for file #{file}" if @heads[file].include?(name)

                    @heads[file][name] = head

                    Log.debug("Registered a new head: #{name}")
                end
            end

            def clear!
                Log.debug("Clearing previously loaded heads")
                @heads = {}
            end

            def heads
                @heads || []
            end

            def files
                @heads.keys
            end
        end

        def initialize
            @dir = File.join(Config.configdir, "heads")
            loadheads
        end

        def feed(file, pos, text)
            loadheads

            return unless Heads.heads.include?(file)

            Heads.heads[file].each_pair do |name, head|
                head.call(file, pos, text)
            end
        end

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

            @loaded = Time.now.to_f
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
    end
end
