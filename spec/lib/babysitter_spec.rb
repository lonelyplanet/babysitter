require 'spec_helper'

describe Babysitter do

  describe '.monitor' do
    it 'returns an instance of Monitor' do
      Babysitter.monitor.should be_an_instance_of(Babysitter::Monitor)
    end
  end

  describe '.configuration' do
    it 'returns an instance of Configuration' do
      Babysitter.configuration.should be_an_instance_of(Babysitter::Configuration)
    end

    it 'returns the same instance every time' do
      c = Babysitter.configuration
      Babysitter.configuration.should eql(c)
    end
  end

  describe '.configure' do
    describe 'object yielded to block' do
      it 'is the unique configuration object' do
        Babysitter.configure do |c|
          c.should eql(Babysitter.configuration)
        end
      end
    end
  end

  describe '.logger' do
    let(:configured_logger) { double('configured logger').as_null_object }

    it 'returns the logger from the configuration' do
      Babysitter::Configuration.any_instance.stub(:logger).and_return(configured_logger)
      Babysitter.logger.should eql(configured_logger)
    end
  end

  describe '.exception_notifiers' do
    let(:exception_notifiers) { double('notifiers').as_null_object}

    it 'returns the notifiers from the configuration' do
      Babysitter::Configuration.any_instance.stub(:exception_notifiers).and_return(exception_notifiers)
      Babysitter.exception_notifiers.should eql(exception_notifiers)
    end
  end

end
