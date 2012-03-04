class Typhon
  class Config
    include Enumerable

    @settings = {:loglevel => :info, :stomp => false, :stat_log_frequency => 3600}

    class << self
      attr_reader :settings

      def []=(key,val)
        @settings[key] = val
      end

      def [](key)
        @settings[key]
      end

      def include?(key)
        @settings.include?(key)
      end

      def each
        @settings.each_pair do |k, v|
          yield({k => v})
        end
      end

      def loadconfig
        raise "Set configdir" unless @settings.include?(:configdir)

        file = File.join([@settings[:configdir], "typhon.yaml"])

        raise "Cannot find file #{file}" unless File.exist?(file)
        @settings.merge!(YAML.load_file(file))
      end

      def method_missing(k, *args, &block)
        return @settings[k] if @settings.include?(k)

        k = k.to_s.gsub("_", ".")
        return @settings[k] if @settings.include?(k)

        super
      end
    end
  end
end

