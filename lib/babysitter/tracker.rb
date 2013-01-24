module Babysitter
  class Tracker
    include Logging

    attr_reader :counting, :stat_name, :counter
    attr_accessor :log_every

    def initialize(log_every, stat_name=nil)
      @stat_name = stat_name
      @counting = :iterations
      @log_every = log_every
      @counter = Counter.new(log_every, stat_name: stat_name, counting: counting)
    end

    def inc(*args)
      counter.inc(*args)
    end

    def count
      counter.count
    end

    def final_report
      counter.log_counter_messsage if counter.final_report?
    end

    def warn(partial_bucket_name, message)
      logger_with_stats_for(partial_bucket_name).warn(message)
    end

    def error(partial_bucket_name, message)
      logger_with_stats_for(partial_bucket_name).error(message)
    end

    def send_total_stats
      counter.send_total_stats
    end

    def logger_with_stats_for(partial_bucket_name)
      @loggers ||= {}
      @loggers[partial_bucket_name] ||= LoggerWithStats.new(fuller_stat_name(partial_bucket_name), tracker: self )
    end

    private

    def fuller_stat_name(partial_bucket_name)
      stat_name+[partial_bucket_name] 
    end

  end

  class LoggerWithStats
    include Logging

    attr_accessor :stat_name_prefix

    STATS_SUFFIX_BY_METHOD = { warn: :warnings, error: :errors, fatal: :fatals }

    def initialize(stat_name_prefix, opts) 
      @stat_name_prefix = stat_name_prefix 
    end

    def method_missing(meth, *opts)
      unless %w{ info debug error fatal}.include?(meth.to_s)
        super
        return
      end
      stats_suffix_from_method(meth).tap{ |suffix| increment(suffix) if suffix }
      logger.send(meth, *opts)
    end

    def warn(*opts)
      increment(stats_suffix_from_method(:warn))
      logger.warn(*opts)
    end

    private

    def stats_suffix_from_method(meth)
      STATS_SUFFIX_BY_METHOD[meth]
    end

    def increment(stat_name_suffix)
      Stats.increment full_stat_name(stat_name_suffix)
    end

    def full_stat_name(stat_name_suffix)
      stat_name_prefix + [stat_name_suffix]
    end

  end

end
