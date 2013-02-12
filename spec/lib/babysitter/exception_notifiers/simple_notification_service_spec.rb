require 'spec_helper'

module Babysitter
  module ExceptionNotifiers
    describe SimpleNotificationService do
      subject { SimpleNotificationService.new(valid_opts) }
      let(:get_credentials_lambda) { -> {
        {
          access_key_id: 'an-access-key-id',
          secret_access_key: 'a-secret-address-key',
        }
      } }
      let(:valid_opts) { {
        credentials: get_credentials_lambda,
        topic_arn: 'my-topic-arn'
      } }
      let(:sns) { double :sns, topics: { 'my-topic-arn' => topic } }
      let(:topic) { double :topic, publish: nil, display_name: "A topic" }
      before :each do
        AWS::SNS.stub(:new).and_return(sns)
      end

      it 'requires a topic_arn' do
        valid_opts.delete :topic_arn
        -> { SimpleNotificationService.new(valid_opts) }.should raise_error(ArgumentError, /topic_arn/)
      end

      it "requires credentials" do
        valid_opts.delete :credentials
        -> { SimpleNotificationService.new(valid_opts) }.should raise_error(ArgumentError, /credentials/)
      end

      it 'requires a block to retrieve AWS credentials' do
        valid_opts[:credentials] = {}
        -> { SimpleNotificationService.new(valid_opts) }.should raise_error(ArgumentError, /credentials/)
      end

      it 'uses the options passed to configure the credentials for sns' do
        AWS::SNS.should_receive(:new).with(get_credentials_lambda.call)
        subject
      end

      it 'validates the topic by checking it has a display name' do
        topic.should_receive(:display_name)
        subject
      end

      describe '.notify' do
        let(:message) { "the message" }
        let(:notification_subject) { "the subject" }

        it 'again uses the options passed to configure the credentials for sns' do
          AWS::SNS.should_receive(:new).with(get_credentials_lambda.call).twice
          subject.notify(notification_subject, message)
        end

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

        it "strips control characters" do
          expected_subject = "this is the subject"
          original_subject = "#{expected_subject}"
          32.times.each { |code| original_subject << code.chr }

          topic.should_receive(:publish).with(message, hash_including(subject: expected_subject))

          subject.notify(original_subject, message)
        end

        it "strips leading whitespace" do
          expected_subject = "this is the subject"
          original_subject = "  #{expected_subject}"

          topic.should_receive(:publish).with(message, hash_including(subject: expected_subject))

          subject.notify(original_subject, message)
        end

        it "handles empty subject" do
          topic.should_receive(:publish).with(message, hash_including(subject: "(no subject)"))

          subject.notify("", message)
        end
      end
    end
  end
end
