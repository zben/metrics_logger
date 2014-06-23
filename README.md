# MetricsLogger

For OpenTSDB data logging

## Installation

Add this line to your application's Gemfile:

    gem 'metrics_logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metrics_logger

## Usage

### Configure Logger
```ruby
  MetricsLogger.configure do |config|
    config.app_name = "my_app"
    config.endpoint = "http://my_opentsdb_server:4242/api/put"
    config.backup_endpoint = "http://my_backup_opentsdb_server:4242/api/put"
    config.interval = 60
```

### Logging Things
#### log arbitrary values
```ruby
MetricsLogger.log("metric_name", key_1: "value_1", key_2: "value_2")
```

#### log duration with block
```ruby
MetricsLogger.log_duration "metric_name" do 
  #do something
end
```
Note: Remember that variables declared inside the block will not be accessible outside the block. If you want to initialize a varaible and use it after block closes, declare the variable before the block.


#### log duration without block
```ruby
logger.MetricsLogger.new

#do something

logger.log_duration "metric_name"
```
#### Log values once per minute
```ruby
MetricsLogger.sample("metric_name", object: some_ruby_object, method: "count")
```

###Start Logger Process
```ruby
Thread.new { MetricsLogger.start }
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/metrics_logger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
