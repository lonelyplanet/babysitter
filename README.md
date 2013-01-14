# Babysitter

A ruby gem that uses [Fozzie](http://github.com/lonelyplanet/fozzie) to report progress on long-running tasks.
When provided with a Logger it will output statistics of progress to the logs.

## Installation

Add this line to your application's Gemfile:

    gem "babysitter", git: 'git@github.com:lonelyplanet/babysitter.git'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install babysitter

## Use


### Configuration

    Babysitter.configure do |c|
      c.logger = MyApp.logger
    end

The default logger does nothing, override if you want to see log output.

### Monitoring

    monitor = Babysitter.monitor("statsd.bucket.name")
    monitor.start("Workername: description") do |progress|
       things_to_do.each do |work|
          do_some work
          progress.inc("Workername: {{count}} tasks completed", 1, counting: :work_things) # report progress here
       end
    end


This will send statistics to StatsD in the supplied bucket name and will generate logs like this:


    INFO -- : Start: update.combinations Matcher generating possible combinations
    INFO -- : Done:  100 combinations generated
    INFO -- : Rate:  20746.88796680498 combinations per second
    INFO -- : End:  update.combinations


Any exceptions that occur will be logged nicely. Exceptions will abort the process.

## Development

    $ git clone git@github.com:lonelyplanet/babysitter.git
    $ cd roverjoe

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
