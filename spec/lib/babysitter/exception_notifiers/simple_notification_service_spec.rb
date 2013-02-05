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
      let(:topic) { double :topic, publish: nil, display_name: "A topic" }
      before :each do
        AWS::SNS.stub(:new).and_return(sns)
      end

      it 'requires a topic_arn' do
        -> { SimpleNotificationService.new() }.should raise_error(ArgumentError, /topic_arn/)
      end

      it 'uses the options passed to configure the credentials for sns' do
        AWS::SNS.should_receive(:new).with(valid_opts.reject { |key| key == :topic_arn } )
        subject
      end

      it 'validates the topic by checking it has a display name' do
        topic.should_receive(:display_name)
        subject
      end

      describe '.notify' do
        let(:message) { "the message" }
        let(:notification_subject) { "the subject" }

        it 'publishes to the topic specified' do
          topic.should_receive(:publish)

          subject.notify(notification_subject, message)
        end

        it 'publishes the message' do
          topic.should_receive(:publish).with(message, hash_including(subject: notification_subject))

          subject.notify(notification_subject, message)
        end

        it "shortens the subject to 100 characters if necessary" do
          shortened_subject = 97.times.map { "x" }.join + "..."
          original_subject = 101.times.map { "x" }.join

          topic.should_receive(:publish).with(message, hash_including(subject: shortened_subject))

          subject.notify(original_subject, message)
        end
      end
    end
  end
end
