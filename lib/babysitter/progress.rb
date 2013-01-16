module Babysitter
  class Progress
    include Logging

    attr_reader :counting, :template, :logged_count, :stat_name
    attr_accessor :log_every

    attr_reader :counter

    def initialize(log_every, stat_name=nil)
      @logged_count = 0
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

    def warn(*args)
      logger.warn(*args)
      send_warning_stat
    end

    def error(*args)
      logger.error(*args)
      send_error_stat
    end

    def send_total_stats
      counter.send_total_stats
    end

    private

    def send_warning_stat
      Stats.increment stat_name+[counting, :warnings] unless stat_name.nil?
    end

    def send_error_stat
      Stats.increment stat_name+[counting, :errors] unless stat_name.nil?
    end

  end
end
