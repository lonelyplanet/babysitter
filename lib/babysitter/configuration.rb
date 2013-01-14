module Babysitter

  class Configuration

    attr_writer :logger

    def logger
      @logger ||= NullLogger.new
    end

  end

end