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
        @topic.publish(msg, subject: sanitise_subject(subject))
      end

      private

      def sanitise_subject(subject)
        sanitised = /\s*([^\x00-\x1F]*)/.match(subject)[1]

        return "(no subject)" if sanitised.empty?
        return sanitised[0..96] + "..." if sanitised.size > 100
        sanitised
      end

      def validate_topic
        @topic.display_name
      end
    end
  end
end
