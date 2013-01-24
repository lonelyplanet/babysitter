

require_relative "babysitter/version"
require_relative "babysitter/null_logger"
require_relative "babysitter/configuration"
require_relative "babysitter/logging"
require_relative "babysitter/logger_with_stats"
require_relative "babysitter/tracker"
require_relative "babysitter/monitor"
require_relative "babysitter/counter"
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


end
