require 'spec_helper'

module Babysitter
  describe Configuration do
    context 'when initialized' do

      let (:null_logger) { double( 'null logger' ) }

      it 'has a default logger set to a new NullLogger' do
        NullLogger.should_receive(:new).and_return( null_logger )
        subject.logger.should === null_logger
      end

      it 'has no exception notifiers' do
        subject.exception_notifiers.should be_empty
      end

    end

    describe 'enabling Amazon simple notification service integration' do
      let (:sns_exception_notifier) { double }
      let (:valid_params) { { 
        access_key_id: "an-access-key",
        secret_access_key: "a-secret-address-key",
        topic_arn: "my-topic-arn" 
      } }

      before :each do
        Babysitter::ExceptionNotifiers::SimpleNotificationService.stub(:new).and_return(sns_exception_notifier)
      end

      it 'requires an access key id' do
        valid_params.delete :access_key_id
        -> { subject.enable_simple_notification_service(valid_params) }.should raise_error(ArgumentError, /access_key_id/)
      end

      it 'requires a secret address key' do
        valid_params.delete :secret_access_key
        -> { subject.enable_simple_notification_service(valid_params) }.should raise_error(ArgumentError, /secret_access_key/)
      end

      it 'requires a topic arn' do
        valid_params.delete :topic_arn
        -> { subject.enable_simple_notification_service(valid_params) }.should raise_error(ArgumentError, /topic_arn/)
      end

      it 'adds an exception notifier' do
        subject.enable_simple_notification_service(valid_params)

        subject.exception_notifiers.should_not be_empty
        subject.exception_notifiers.first.should eql(sns_exception_notifier)
      end

      it 'configures the exception notifier' do
        ExceptionNotifiers::SimpleNotificationService.should_receive(:new).with(hash_including(valid_params))

        subject.enable_simple_notification_service(valid_params)
      end
    end

  end
end
