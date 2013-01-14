require 'spec_helper'

module Babysitter
  describe Configuration do
    context 'when initialized' do

      let (:null_logger) { double( 'null logger' ) }

      it 'has a default logger set to a new NullLogger' do
        NullLogger.should_receive(:new).and_return( null_logger )
        subject.logger.should === null_logger
      end

    end

  end
end