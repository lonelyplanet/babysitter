require 'aws-sdk'

module Babysitter
  module ExceptionNotifiers
    class SimpleNotificationService
      def initialize(opts = {})
        @topic_arn = opts.delete(:topic_arn)
        @get_credentials = opts.delete(:credentials)
        raise ArgumentError, "topic_arn is required." if @topic_arn.nil?
        raise ArgumentError, "credentials is required and must be a Proc." if @get_credentials.nil? || !@get_credentials.is_a?(Proc)

        validate_topic
      end

      def notify(subject, msg)
        topic.publish(msg, subject: sanitise_subject(subject))
      end

      private

      def sns
        AWS::SNS.new(@get_credentials.call)
      end

      def topic
        sns.topics[@topic_arn]
      end

      def sanitise_subject(subject)
        sanitised = /\s*([^\x00-\x1F]*)/.match(subject)[1]

        return "(no subject)" if sanitised.empty?
        return sanitised[0..96] + "..." if sanitised.size > 100
        sanitised
      end

      def validate_topic
        topic.display_name
      end
    end
  end
end
