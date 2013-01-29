module Babysitter

  class Configuration

    attr_writer :logger
    attr_reader :exception_notifiers

    def initialize
      @exception_notifiers = []
    end

    def logger
      @logger ||= NullLogger.new
    end

    def enable_simple_notification_service(opts = {})
      [:access_key_id, :secret_access_key, :topic_arn].each do |key|
        raise ArgumentError, "#{key} is required" unless opts.has_key?(key)
      end

      @exception_notifiers << ExceptionNotifiers::SimpleNotificationService.new(opts)
    end

  end

end
