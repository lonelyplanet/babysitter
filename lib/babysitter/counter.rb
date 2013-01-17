module Babysitter
  class Counter
    include Logging

    attr_reader :count, :log_every, :template, :logged_count, :stat_name, :counting

    attr_accessor :template

    def initialize(log_every, opts)
      @count = 0
      @logged_count = 0
      @log_every = log_every
      @stat_name = opts.delete(:stat_name)
      @counting = opts.delete(:counting)
      @timer_start = Time.now
    end

    def inc( template, amount=1, opts={} )
      @template = template
      new_counting = opts.delete(:counting)
      @counting = new_counting unless new_counting.nil?
      log_this_time = block_number(@count) != block_number(@count + amount)
      @count += amount
      log_counter_messsage if log_this_time
      @timer_start = Time.now
    end

    def block_number(count)
      count / @log_every
    end

    def final_report?
      !(template.nil? or template.empty?) && count != logged_count
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

    def send_total_stats
      Stats.gauge stat_name+[counting, :total], count
    end

  end
end
