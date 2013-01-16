require 'spec_helper'

module Babysitter
  describe Progress  do
    before(:each) do
      Stats.stub!(:count).with(anything, anything)
      Stats.stub!(:gauge).with(anything, anything)
    end

    context 'when initialized with a dot separated bucket name' do

      subject{ Progress.new(bucket_name) }
      let(:bucket_name) { 'my.splendid.bucket.name' }
      let(:start_block) { Proc.new{ block_result } }
      let(:block_result) { double('block result').as_null_object }
      let(:logger)       { double('logger').as_null_object }

      describe '#completed' do
        it 'logs a done message' do
          Progress.any_instance.stub(:logger).and_return(logger)
          logger.should_receive(:info).with("Done:  the completed thing")
          subject.completed('the completed thing')
        end
      end

      describe '#start' do

        it 'yields to the block, returning the result' do
          subject.start(&start_block).should === block_result
        end

        it 'calls Stats.time_to_do with the bucket name' do
          expected_stat = bucket_name.split('.')+[:overall]
          Stats.should_receive(:time_to_do).with(expected_stat)
          subject.start(&start_block)
        end

        it 'calls logger.info with start message' do
          Progress.any_instance.stub(:logger).and_return(logger)
          logger.should_receive(:info).with("Start: #{bucket_name}")
          subject.start(&start_block)
        end

        it 'calls logger.info with end message' do
          Progress.any_instance.stub(:logger).and_return(logger)
          logger.should_receive(:info).with("End:   #{bucket_name}")
          subject.start(&start_block)
        end

        context 'when the start method is given a message' do
          it 'calls logger.info with start message' do
            Progress.any_instance.stub(:logger).and_return(logger)
            logger.should_receive(:info).with("Start: #{bucket_name} special message")
            subject.start('special message', &start_block)
          end

          it 'calls logger.info with end message' do
            Progress.any_instance.stub(:logger).and_return(logger)
            logger.should_receive(:info).with("End:   #{bucket_name} special message")
            subject.start('special message', &start_block)
          end
        end

        context 'when the block increments the counter twice, each with a count of 5, and identifies counted objects' do
          let(:start_block_two_increments) do
            Proc.new do |counter|
              2.times{ counter.inc('incrementing by {{count}} things', 5, counting: :things) }
            end
          end

          it 'calls Stats.count with bucket name plus counted objects, and a count of 10' do
            expected_bucket_name = bucket_name.split('.') + [:things, :total]
            Stats.should_receive(:gauge).with(expected_bucket_name, 10)
            subject.start(&start_block_two_increments)
          end

          it 'calls logger.info with each done message once' do
            ProgressCounter.any_instance.stub(:logger).and_return(logger)
            [5,10].each { |inc| logger.should_receive(:info).with( "Done:  incrementing by #{inc} things").once }
            subject.start('short message', 5, &start_block_two_increments)
          end
        end # context 'when the block increments the counter twice, each with a count of 5, and identifies counted objects'

        context 'when the block increments the counter 7 times, with no amount specified, and no name for counted objects' do
          let(:start_block_seven_increments) do
            Proc.new do |counter|
              7.times{ counter.inc('incrementing by {{count}} things') }
            end
          end

          it 'calls Stats.count with bucket name plus iterations, and a count of 7' do
            expected_bucket_name = bucket_name.split('.') + [:iterations, :total]
            Stats.should_receive(:gauge).with(expected_bucket_name, 7)
            subject.start(&start_block_seven_increments)
          end

          it 'calls logger.info with each done message once' do
            ProgressCounter.any_instance.stub(:logger).and_return(logger)
            [5,7].each { |inc| logger.should_receive(:info).with( "Done:  incrementing by #{inc} things").once }
            subject.start('short message', 5, &start_block_seven_increments)
          end
        end # context 'when the block increments the counter 7 times, with no amount specified, and no name for counted objects'

        context 'when logging every 10th call, and the block increments the counter 7 times, each with a count of 9, and identifies counted objects' do
          let(:start_block_three_increments) do
            Proc.new do |counter|
              7.times{ counter.inc('incrementing by {{count}} things', 9, counting: :things) }
            end
          end

          it 'calls logger.info with increments 18,27,36,45,54,63' do
            ProgressCounter.any_instance.stub(:logger).and_return(logger)
            [18,27,36,45,54,63].each { |inc| logger.should_receive(:info).with( "Done:  incrementing by #{inc} things").once }
            subject.start('short message', 10, &start_block_three_increments)
          end
        end # context 'when logging every 10th call, and the block increments the counter 7 times, each with a count of 9, and identifies counted objects' do

        context "when the block logs a warning" do 
          let(:start_block_with_warning) do
            Proc.new do |monitor|
              monitor.warn('my warning message')
            end
          end

          it 'calls logger.info with the warning message' do
            ProgressCounter.any_instance.stub(:logger).and_return(logger)
            logger.should_receive(:warn).with( "my warning message")
            Stats.stub!(:increment)
            subject.start(&start_block_with_warning)
          end

          it 'calls Stats.count with warning bucket name' do
            expected_bucket_name = bucket_name.split('.') + [:iterations, :warnings]
            Stats.should_receive(:increment).with(expected_bucket_name)
            subject.start(&start_block_with_warning)
          end
        end

        context "when the block logs an error" do 
          let(:start_block_with_error) do
            Proc.new do |monitor|
              monitor.error('my error message')
            end
          end

          it 'calls logger.error with the error message' do
            ProgressCounter.any_instance.stub(:logger).and_return(logger)
            logger.should_receive(:error).with( "my error message")
            Stats.stub!(:increment)
            subject.start(&start_block_with_error)
          end

          it 'calls Stats.count with error bucket name' do
            expected_bucket_name = bucket_name.split('.') + [:iterations, :errors]
            Stats.should_receive(:increment).with(expected_bucket_name)
            subject.start(&start_block_with_error)
          end
        end

      end

    end

  end
end
