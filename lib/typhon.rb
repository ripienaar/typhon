class Typhon
    require 'rubygems'
    require 'eventmachine'
    require 'eventmachine-tail'
    require 'typhon/heads'

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
    end

    attr_reader :heads

    def initialize(path="/etc/typhon/heads")
        @heads = Heads.new(path)
    end

    def tail
        EM.run do
            Typhon.files.each do |path|
                EventMachine::file_tail(path) do |ft, line|
                    @heads.feed(ft.path, ft.position, line)
                end
            end
        end
    end
end
