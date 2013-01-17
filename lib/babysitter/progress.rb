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
      logger.warn(message)
      send_warning_stat(partial_bucket_name)
    end

    def error(partial_bucket_name, message)
      logger.error(message)
      send_error_stat(partial_bucket_name)
    end

    def send_total_stats
      counter.send_total_stats
    end

    private

    def send_warning_stat(partial_bucket_name)
      Stats.increment stat_name+[partial_bucket_name, :warnings] unless stat_name.nil?
    end

    def send_error_stat(partial_bucket_name)
      Stats.increment stat_name+[partial_bucket_name, :errors] unless stat_name.nil?
    end

  end
end
