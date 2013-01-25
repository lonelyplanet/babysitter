module Babysitter
  class LoggerWithStats
    include Logging

    attr_accessor :stat_name_prefix

    STATS_SUFFIX_BY_METHOD = { warn: :warnings, error: :errors, fatal: :fatals }

    def initialize(stat_name_prefix) 
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
