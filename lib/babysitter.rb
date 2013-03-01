

require_relative "babysitter/version"
require_relative "babysitter/null_logger"
require_relative "babysitter/configuration"
require_relative "babysitter/logging"
require_relative "babysitter/logger_with_stats"
require_relative "babysitter/tracker"
require_relative "babysitter/monitor"
require_relative "babysitter/counter"
require_relative "babysitter/exception_notifiers"
require_relative "babysitter/logger_with_deprecation"
require 'fozzie'

module Babysitter

  def self.monitor(*args)
    Monitor.new(*args)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.logger
    configuration.logger
  end

  def self.exception_notifiers
    configuration.exception_notifiers
  end

end
