module Babysitter
  class Monitor
    include Logging

    attr_accessor :stat_name

    def initialize(stat_name=nil)
      @stat_name = convert_stat_name_to_array(stat_name)
    end

    def start(msg=nil, log_every=100, &blk)
      raise ArgumentError, "Stats bucket name must not be blank" if stat_name.nil? or stat_name.empty?
      log_msg = format_log_message(msg)
      counter = Progress.new(log_every, stat_name)
      logger.info "Start: #{log_msg}"

      begin
        result = Stats.time_to_do stat_name+[:overall] do
          blk.call(counter)
        end
      rescue Exception => e
        counter.final_report rescue nil
        log_exception_details( log_msg, e )
        raise
      end

      counter.send_total_stats
      counter.final_report
      logger.info "End:   #{log_msg}"
      result
    end

    def completed(msg)
      logger.info "Done:  #{msg}"
    end

    private

    def format_log_message(msg)
      log_msg = stat_name.join('.')
      [log_msg,msg].compact.join(' ')
    end

    def convert_stat_name_to_array(stat_name)
      stat_name.is_a?(Array) ? stat_name : stat_name.split('.') unless stat_name.nil? or stat_name.empty?
    end

    def log_exception_details( msg, exception )
      logger.error "Aborting: #{msg} due to exception #{exception.class}: #{exception}"
      if exception.backtrace
        exception.backtrace.each { |line| Babysitter.logger.error "    #{line}" }
      end
    end
  end


end
