module Babysitter

  class NullLogger

    def method_missing( *args )
      self
    end

  end

end
