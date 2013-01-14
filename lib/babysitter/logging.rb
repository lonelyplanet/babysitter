module Babysitter
  module Logging

    def log_file_exceptions(file, &block)
      begin
        block.call(file)
      rescue Exception
        logger.error "Exception processing file #{file}"
        raise
      end
    end

    def logger
      Babysitter.logger
    end

  end
end
