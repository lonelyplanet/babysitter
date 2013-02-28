module Babysitter

  class LoggerWithDeprecation

    attr_reader :delegate
    
    def initialize(opts={})
      @delegate = opts.delete(:logger) || Babysitter.configuration.logger
    end

    def self.notice(caller)
      return if caller_has_been_logged?(caller)
      Kernel.warn("[DEPRECATED] You are using old style logging. Please use tracker (yielded by monitor.start) instead. Caller was #{caller.first}")
      Kernel.warn("[DEPRECATED] See https://github.com/lonelyplanet/rowlf/blob/master/LOGGING.md for more info")
    end

    def warn(*args)
      self.class.notice(caller)
      delegate.warn(*args)
    end

    def error(*args)
      self.class.notice(caller)
      delegate.error(*args)
    end

    def info(*args)
      delegate.info(*args)
    end

    def debug(*args)
      delegate.debug(*args)
    end

    def fatal(*args)
      delegate.fatal(*args)
    end

    private

    def self.caller_has_been_logged?(caller)
      return true if caller_seen.include?(caller.first)
      caller_seen << caller.first
      return false
    end

    def self.caller_seen
      @caller_seen ||= []
    end

  end

end
