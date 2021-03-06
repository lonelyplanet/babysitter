require 'spec_helper'

module Babysitter
  describe Monitor do
    before(:each) do
      Stats.stub!(:count).with(anything, anything)
      Stats.stub!(:gauge).with(anything, anything)
    end

    context 'when initialized with a dot separated bucket name' do

      subject{ Monitor.new(bucket_name) }
      let(:bucket_name) { 'my.splendid.bucket.name' }
      let(:start_block) { Proc.new{ block_result } }
      let(:block_result) { double('block result').as_null_object }
      let(:logger)       { double('logger').as_null_object }

      describe '#completed' do
        it 'logs a done message' do
          Monitor.any_instance.stub(:logger).and_return(logger)
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
          Monitor.any_instance.stub(:logger).and_return(logger)
          logger.should_receive(:info).with("Start: #{bucket_name}")
          subject.start(&start_block)
        end

        it 'calls logger.info with end message' do
          Monitor.any_instance.stub(:logger).and_return(logger)
          logger.should_receive(:info).with("End:   #{bucket_name}")
          subject.start(&start_block)
        end

        context 'when the start method is given a message' do
          it 'calls logger.info with start message' do
            Monitor.any_instance.stub(:logger).and_return(logger)
            logger.should_receive(:info).with("Start: #{bucket_name} special message")
            subject.start('special message', &start_block)
          end

          it 'calls logger.info with end message' do
            Monitor.any_instance.stub(:logger).and_return(logger)
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
            Counter.any_instance.stub(:logger).and_return(logger)
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
            Counter.any_instance.stub(:logger).and_return(logger)
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
            Counter.any_instance.stub(:logger).and_return(logger)
            [18,27,36,45,54,63].each { |inc| logger.should_receive(:info).with( "Done:  incrementing by #{inc} things").once }
            subject.start('short message', 10, &start_block_three_increments)
          end
        end # context 'when logging every 10th call, and the block increments the counter 7 times, each with a count of 9, and identifies counted objects' do

        context 'when the block logs 3 increments to oranges counter, and 5 increments to apples:' do 
          let(:start_block_3_oranges_5_apples) do
            Proc.new do |tracker|
              3.times{ tracker.inc('{{count}} oranges counted', 1, counting: :orangey_things) }
              5.times{ tracker.inc('{{count}} apples counted', 1, counting: :appley_things) }
            end
          end
          
          it 'calls logger with 3 oranges counted and 5 apples counted' do
            Counter.any_instance.stub(:logger).and_return(logger)
            logger.stub(:info).with(anything) 
            logger.should_receive(:info).with(/3 oranges counted/)
            logger.should_receive(:info).with(/5 apples counted/)
            subject.start('short message', 10, &start_block_3_oranges_5_apples)
          end

        end # context 'when the block logs 3 increments to oranges counter, and 5 increments to apples:' do 

        context "when the block logs a warning" do 
          let(:start_block_with_warning) do
            Proc.new do |monitor|
              monitor.warn(:my_warning_bucket, 'my warning message')
            end
          end
          before(:each) do
            Babysitter.stub(:logger).and_return(logger)
            logger.stub!(:warn)
            Stats.stub!(:increment)
          end

          it 'calls logger.info with the warning message' do
            logger.should_receive(:warn).with( "my warning message")
            subject.start(&start_block_with_warning)
          end

          it 'calls Stats.count with warning bucket name' do
            expected_bucket_name = bucket_name.split('.') + [:my_warning_bucket, :warnings]
            Stats.should_receive(:increment).with(expected_bucket_name)
            subject.start(&start_block_with_warning)
          end
        end

        context "when the block logs an error" do 
          let(:start_block_with_error) do
            Proc.new do |monitor|
              monitor.error(:my_error_bucket, 'my error message')
            end
          end
          before(:each) do
            Babysitter.stub(:logger).and_return(logger)
            logger.stub!(:error)
            Stats.stub!(:increment)
          end

          it 'calls logger.error with the error message' do
            logger.should_receive(:error).with( "my error message")
            subject.start(&start_block_with_error)
          end

          it 'calls Stats.count with error bucket name' do
            expected_bucket_name = bucket_name.split('.') + [:my_error_bucket, :errors]
            Stats.should_receive(:increment).with(expected_bucket_name)
            subject.start(&start_block_with_error)
          end
        end

        context 'when the block raises an error' do
          let(:error) { RuntimeError.new(error_message) }
          let(:backtrace) { 3.times.map { |i| "Line #{i}"} }
          let(:error_message) { 'A big fat error' }
          let(:expected_message) { "Aborting: #{bucket_name} due to exception RuntimeError: #{error_message}" }
          let(:start_block_with_error) { Proc.new { raise error } }
          before(:each) do
            error.stub(:backtrace).and_return(backtrace)
            Babysitter.stub(:logger).and_return(logger)
            Babysitter.stub(:exception_notifiers).and_return(2.times.map { double notify: nil  })
            logger.stub!(:error)
            Stats.stub!(:increment)
          end

          it 'calls logger.error with the exeption details' do
            logger.should_receive(:error).with(expected_message)
            backtrace.each do |line|
              logger.should_receive(:error).with(/\w*#{line}/)
            end

            begin
              subject.start(&start_block_with_error)
            rescue
            end
          end
          
          it 'calls each exception notifier with the exception details' do
            message = [expected_message].concat(backtrace).join("\n")

            Babysitter.exception_notifiers.each do |exception_notifier|
              exception_notifier.should_receive(:notify).with('RuntimeError', message)
            end

            begin
              subject.start(&start_block_with_error)
            rescue
            end
          end
        end

        context 'when the block increments 2 times at intervals of 2 seconds' do
          let(:start_block_for_timing) do
            Proc.new do |counter|
              2.times do
                Timecop.travel(Time.now+2) # move on 2 seconds
                counter.inc('doing increment',1)
              end
            end
          end
          before(:each) { Timecop.travel(Time.now) }
          after(:each)  { Timecop.return           }

          it 'calculates a rate close to 0.5 per second' do
            Counter.any_instance.should_receive(:send_rate_stats) do |rate|
              rate.should be_within(0.01).of(0.5)
            end
            subject.start(&start_block_for_timing)
          end
        end

      end

    end

  end
end
