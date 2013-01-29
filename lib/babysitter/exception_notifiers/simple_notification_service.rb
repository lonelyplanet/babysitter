require 'aws-sdk'

module Babysitter
  module ExceptionNotifiers
    class SimpleNotificationService
      def initialize(opts)
        access_key = opts.delete :access_key_id
        secret_access_key = opts.delete :secret_access_key
        @sns = AWS::SNS.new(access_key_id: access_key, secret_access_key: secret_access_key)
        @topic = @sns.topics[opts.delete(:topic_arn)]
      end

      def notify(msg)
        @topic.publish(msg)
      end
    end
  end
end
