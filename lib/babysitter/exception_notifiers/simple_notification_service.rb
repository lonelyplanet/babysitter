require 'aws-sdk'

module Babysitter
  module ExceptionNotifiers
    class SimpleNotificationService
      def initialize(opts = {})
        topic_arn = opts.delete(:topic_arn)
        raise ArgumentError, "topic_arn is required." if topic_arn.nil?

        @sns = AWS::SNS.new(opts)
        @topic = @sns.topics[topic_arn]
        validate_topic
      end

      def notify(subject, msg)
        sanitised_subject = if subject.size > 100
                              subject[0..96] + "..."
                            else
                              subject
                            end
        @topic.publish(msg, subject: sanitised_subject)
      end

      private

      def validate_topic
        @topic.display_name
      end
    end
  end
end
