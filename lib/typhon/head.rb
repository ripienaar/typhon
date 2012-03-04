class Typhon
  # heads get loaded into this class on the 'call' method, provides convenient access
  # to stomp, rate limiters etc
  class Head
    def define_singleton_method(*args, &block)
      class << self
        self
      end.send(:define_method, *args, &block)
    end unless method_defined? :define_singleton_method

    def ratelimit(name, time=60)
      @limiters ||= {}

      @limiters[name] ||= RateLimit.new(time)
    end

    def stomp
      Typhon.stomp
    end
  end
end
