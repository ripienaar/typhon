class Typhon
  class RateLimit
    require 'digest/md5'

    attr_reader :timespan

    # timespan - how many seconds you want to track events for.
    #            events older than this will drop off the queue
    def initialize(timespan)
      @timespan = timespan
      @events = []
    end

    # Record that an event happened
    #
    # Just pass in any text, unique text will be tracked individually
    def record(event)
      key = Digest::MD5.hexdigest(event)

      event = {:k => key,
               :t => Time.now.to_f}

      @events << event

      domaint
    end

    # How many times have the event been seen in the last interval
    def rate(event)
      key = Digest::MD5.hexdigest(event)

      @events.select{|e| e[:k] == key}.size
    end

    private
    # Deletes events older than the defined timespan
    def domaint
      @events.each_with_index do |event, idx|
        # events are stored in time order delete them till we find ont thats
        # newer then we can stop looking
        if event[:t].to_f < (Time.now.to_f - @timespan.to_f)
          @events.delete_at(idx)
        else
          return
        end
      end
    end
  end
end
