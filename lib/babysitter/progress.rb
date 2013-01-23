module Babysitter
  class Progress
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
      logger_with_fozzie_for(partial_bucket_name).warn(message)
    end

    def error(partial_bucket_name, message)
      logger_with_fozzie_for(partial_bucket_name).error(message)
    end

    def send_total_stats
      counter.send_total_stats
    end

    private

    def logger_with_fozzie_for(partial_bucket_name)
      @loggers ||= {}
      @loggers[partial_bucket_name] ||= LoggerWithFozzie.new(fuller_stat_name(partial_bucket_name), progress: self )
    end

    def fuller_stat_name(partial_bucket_name)
      stat_name+[partial_bucket_name] 
    end

  end

  class LoggerWithFozzie

    attr_accessor :stat_name_prefix, :progress

    STATS_SUFFIX_BY_METHOD = { warn: :warnings, error: :errors }

    def initialize(stat_name_prefix, opts) 
      @stat_name_prefix = stat_name_prefix 
      @progress = opts.delete(:progress)
    end

    # TODO: This bears a very strong resemblance to the two methods warn and error
    # on Babysitter::Progress . How to DRY this ?

    def method_missing(meth, *opts)
      raise "bad call for #{meth.inspect}" unless %w{ warn error }.include?(meth.to_s)
      increment(stats_suffix_from_method(meth))
      progress.logger.send(meth, *opts)
    end

    def stats_suffix_from_method(meth)
      STATS_SUFFIX_BY_METHOD[meth]
    end

    def increment(stat_name_suffix)
      Stats.increment full_stat_name(stat_name_suffix)
    end

    private

    def full_stat_name(stat_name_suffix)
      stat_name_prefix + [stat_name_suffix]
    end

  end

end
