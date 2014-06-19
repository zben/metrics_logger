module MetricsLogger
  class MetricsLogger
    def initialize
      @start_time_in_milliseconds = Time.now.to_f * 1000
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    def log_duration(type)
      end_time = Time.now
      end_time_in_milliseconds = end_time.to_f * 1000
      duration = end_time_in_milliseconds - @start_time_in_milliseconds
      metric = {duration: duration}
      self.class.enqueue(type, metric)
    end

    #Class Methods
    def self.log(type, metrics)
      metrics.each do |key, value|
        self.enqueue(type, key => value)
      end
    end

    def self.log_duration(type, &blk)
      logger = self.new
      yield
      logger.log_duration(type)
    end

    def self.enqueue(type, metric)
      key = metric.to_a[0][0]
      value = metric.to_a[0][1]
      puts caller.inspect if value.nil?

      sub_type = "#{type}.#{key}"

      queue[sub_type] ||= ThreadSafe::Array.new
      queue[sub_type].push value
      nil
    end

    def self.queue
      @queue ||= ThreadSafe::Hash.new
    end

    def self.sampling_definitions
      @sampling_definitions ||= ThreadSafe::Array.new
    end

    def self.reset
      @queue = ThreadSafe::Hash.new
      @sampling_definitions = ThreadSafe::Array.new
    end

    def self.sync
      @queue, batched_data = ThreadSafe::Hash.new, queue

      data = []
      timestamp = (Time.now.to_f * 1000).to_i
      app_name = configuration.app_name

      batched_data.each do |sub_type, values|
        total = values.compact.inject(:+)
        count = values.count
        average = total.to_f / count

        data << {metric: "#{app_name}.#{sub_type}.total", timestamp: timestamp, value: total, tags: configuration.tags}
        data << {metric: "#{app_name}.#{sub_type}.count", timestamp: timestamp, value: count, tags: configuration.tags}
        data << {metric: "#{app_name}.#{sub_type}.average", timestamp: timestamp, value: average, tags: configuration.tags}
      end

      sampling_definitions.each do |defintion|
        value = defintion[:object].send(defintion[:method])
        data << {metric: "#{app_name}.#{defintion[:name]}", timestamp: timestamp, value: value, tags: configuration.tags}
      end

      send_data(data) if data[0]
    end

    def self.send_data(data)
      begin
        Faraday.post(configuration.endpoint, data.to_json)
      rescue
        begin
          Faraday.post(configuration.backup_endpoint, data.to_json)
        rescue
          puts "#{Time.now} Cannot reach metrics server."
        end
      end
    end

    def self.sample(name, options = {})
      sampling_definitions << {name: name, object: options[:object], method: options[:method]}
    end

    def self.start
      raise "Must specify app name in MetricsLogger configuration" unless configuration.app_name
      raise "Must specify endpoint in MetricsLogger configuration" unless configuration.endpoint

      while true
        sleep configuration.sync_interval
        sync
      end
    end
  end
end
