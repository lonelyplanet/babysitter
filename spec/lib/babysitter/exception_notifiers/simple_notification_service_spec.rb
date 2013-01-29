require 'spec_helper'

module Babysitter
  module ExceptionNotifiers
    describe SimpleNotificationService do
      subject { SimpleNotificationService.new(valid_opts) }
      let(:valid_opts) { {
        access_key_id: 'an-access-key-id',
        secret_access_key: 'a-secret-address-key',
        topic_arn: 'my-topic-arn'
      } }
      let(:sns) { double :sns, topics: { 'my-topic-arn' => topic } }
      let(:topic) { double :topic, publish: nil }
      before :each do
        AWS::SNS.stub(:new).and_return(sns)
      end

      it 'uses the options passed to configure the credentials for sns' do
        AWS::SNS.should_receive(:new).with(valid_opts.reject { |key| key == :topic_arn } )
        subject
      end

      describe '.notify' do
        let(:message) { "the message" }
        it 'publishes to the topic specified' do
          topic.should_receive(:publish)

          subject.notify(message)
        end

        it 'publishes the message' do
          topic.should_receive(:publish).with(message)

          subject.notify(message)
        end
      end
    end
  end
end
