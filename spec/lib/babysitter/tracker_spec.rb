require 'spec_helper'

module Babysitter
  describe Tracker do

    subject{ Tracker.new(log_interval, stat_bucket_prefix) }
    let(:log_interval) { 5 }
    let(:stat_bucket_prefix) { [:my, :stat, :bucket, :prefix] }
    let(:logger) { double('boring old vanilla babysitter logger') }
    before(:each) do
      Babysitter.stub(:logger).and_return(logger)
    end

    describe '.new' do
      let(:stat_bucket_prefix) { 'my.stat.bucket.prefix' }

      it 'converts string stat_name to array' do
        subject.stat_name.should == %w(my stat bucket prefix)
      end
    end

    describe '#logger_with_stats_for' do

      it 'returns the same logger when passed the same symbol twice' do
        l1 = subject.logger_with_stats_for(:lodgings)
        l2 = subject.logger_with_stats_for(:lodgings)
        l1.should be_equal(l2)
      end

      it 'returns different loggers when passed different symbols' do
        l = subject.logger_with_stats_for(:lodgings)
        p = subject.logger_with_stats_for(:places)
        l.should_not be_equal(p)
      end

    end # describe '#logger_with_stats' do

    describe 'logger returned by logger_with_stats_for(some_topic)' do
      subject{ Tracker.new(log_interval, stat_bucket_prefix).logger_with_stats_for(some_topic) }
      let(:some_topic) { :some_topic }
      let(:text_of_the_message) {'the message we want in the logs'}

      { warn: :warnings, error: :errors, fatal: :fatals }.each do |message_type, stats_bucket_suffix|
        describe "##{message_type}" do
          before(:each) do
            logger.stub(message_type)
            Stats.stub!(:increment)
          end

          it 'logs the message' do
            logger.should_receive(message_type).with(text_of_the_message)
            subject.send(message_type, text_of_the_message)
          end

          it 'sends the stats' do
            expected_stats_bucket = stat_bucket_prefix + [some_topic, stats_bucket_suffix] 
            Stats.should_receive(:increment).with(expected_stats_bucket) 
            subject.send(message_type, text_of_the_message)
          end
        end

      end

      [:info, :debug].each do |message_type|
        describe "##{message_type}" do
          before(:each) do
            logger.stub(message_type)
            Stats.stub!(:increment)
          end

          it 'logs the message' do
            logger.should_receive(message_type).with(text_of_the_message)
            subject.send(message_type, text_of_the_message)
          end

          it 'sends no stats' do
            Stats.should_not_receive(:increment)
            subject.send(message_type, text_of_the_message)
          end
        end

      end

    end # describe 'logger returned by logger_with_stats_for(:something)' do

    describe 'counting:' do

      context 'inc called 3 times, with no :counting' do
        before(:each) do
          subject.inc('some message', 3)
          logger.stub(:info)
        end

        it 'the counter should be 3' do 
          subject.counter.count.should == 3
        end

        context 'and then incremented by 5 with no :counting' do
          before(:each) do
            subject.inc('some message', 5)
          end

          it 'the counter should be 8' do 
            subject.counter.count.should == 8
          end
        end

        context 'and then incremented by 5 with :counting => apples' do
          before(:each) do
            subject.inc('some message', 5, counting: :apples)
          end

          it 'the counter should be 3' do 
            subject.counter.count.should == 3
          end

          it 'the apples counter should be 5' do 
            subject.counter(:apples).count.should == 5
          end
          
          context 'and then incremented by 4 with :counting => oranges' do
            before(:each) do
              subject.inc('some message', 4, counting: :oranges)
            end

            it 'the counter should be 3' do 
              subject.counter.count.should == 3
            end

            it 'the apples counter should be 5' do 
              subject.counter(:apples).count.should == 5
            end

            it 'the oranges counter should be 4' do 
              subject.counter(:oranges).count.should == 4
            end
            
          end
          
        end

      end

    end # describe 'counting:' do

  end # describe Tracker do

end


