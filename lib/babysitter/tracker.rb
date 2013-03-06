module Babysitter
  class Tracker
    include Logging

    attr_reader :counting, :stat_name, :timer_start
    attr_accessor :log_every

    def initialize(log_every, stat_name=nil)
      @stat_name = stat_name.is_a?(String) ? stat_name.split('.') : stat_name
      @counting = default_counting
      @log_every = log_every
      @timer_start = Time.now
      @counters = Hash.new do |h, k|
        h[k] = Counter.new(log_every, stat_name: @stat_name, counting: k, timer_start: timer_start)
      end
    end

    def inc(template, inc=1, opts={})
      counting = opts[:counting] || default_counting
      counter(counting).inc(template, inc, opts)
    end

    def counter(counting=default_counting)
      @counters[counting]
    end

    def count
      counter.count
    end

    def final_report
      @counters.values.each do |counter|
        counter.log_counter_messsage if counter.final_report?
      end
    end

    def warn(topic_name, message)
      logger_with_stats_for(topic_name).warn(message)
    end

    def error(topic_name, message)
      logger_with_stats_for(topic_name).error(message)
    end

    def send_total_stats
      @counters.values.each do |counter|
        counter.send_total_stats
      end
    end

    def logger_with_stats_for(topic_name)
      @loggers ||= {}
      @loggers[topic_name] ||= LoggerWithStats.new(stats_prefix_for_topic(topic_name))
    end

    private

    def stats_prefix_for_topic(topic_name)
      stat_name+[topic_name] 
    end

    def default_counting
      :iterations
    end

  end

end
