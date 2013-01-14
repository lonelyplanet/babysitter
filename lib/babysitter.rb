

require_relative "babysitter/version"
require_relative "babysitter/null_logger"
require_relative "babysitter/configuration"
require_relative "babysitter/logging"
require_relative "babysitter/progress_counter"
require_relative "babysitter/progress"


module Babysitter

  def self.monitor(*args)
    Progress.new(*args)
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