module Babysitter
  class ProgressCounter
    include Logging

    attr_reader :count, :counting, :template, :logged_count, :stat_name
    attr_accessor :log_every

    def initialize(log_every, stat_name=nil)
      @count = 0
      @logged_count = 0
      @stat_name = stat_name
      @counting = :iterations
      @log_every = log_every
      @timer_start = Time.now
    end

    def inc( template, amount=1, opts={} )
      @template = template
      new_counting = opts.delete(:counting)
      @counting = new_counting unless new_counting.nil?
      log_this_time = block_number(@count) != block_number(@count + amount)
      @count += amount
      log_counter_messsage if log_this_time
    end

    def final_report
      log_counter_messsage if !(template.nil? or template.empty?) && count != logged_count
    end

    def warn(*args)
      logger.warn(*args)
      send_warning_stat
    end

    def error(*args)
      logger.error(*args)
      send_error_stat
    end

    private

    def block_number(count)
      count / @log_every
    end

    def log_counter_messsage
      logger.info( "Done:  #{template.gsub("{{count}}", count.to_s)}" )
      send_progress_stats(count - logged_count)

      rate = (count - logged_count).to_f / (Time.now - @timer_start)
      logger.info( "Rate:  #{rate} #{counting} per second" )
      send_rate_stats(rate)

      @logged_count = count
      @timer_start = Time.now
    end

    def send_rate_stats(rate)
      Stats.gauge stat_name+[counting, :rate], rate unless stat_name.nil?
    end

    def send_progress_stats(progress)
      Stats.count stat_name+[counting, :progress], progress unless stat_name.nil?
    end

    def send_warning_stat
      Stats.increment stat_name+[counting, :warnings] unless stat_name.nil?
    end

    def send_error_stat
      Stats.increment stat_name+[counting, :errors] unless stat_name.nil?
    end

  end
end
