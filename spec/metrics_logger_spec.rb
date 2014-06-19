require 'spec_helper'

describe MetricsLogger do
  after do
    MetricsLogger.reset
    Timecop.return
  end

  describe ".configure" do
    before do
      MetricsLogger.configure do |config|
        config.endpoint = "http://movefast1.snc1:4242/test"
        config.backup_endpoint = "http://movefast5.snc1:4242/test"
        config.sync_interval = 60
      end
    end

    it "sets correct endpoint and backup endpoint" do
      expect(MetricsLogger.configuration.endpoint).to eq("http://movefast1.snc1:4242/test")
      expect(MetricsLogger.configuration.backup_endpoint).to eq("http://movefast5.snc1:4242/test")
      expect(MetricsLogger.configuration.sync_interval).to eq(60)
    end
  end

  describe "#log_duration" do
    it "logs correct duration" do
      Timecop.freeze(Time.parse("2014-01-01 1:0:0"))
      logger = MetricsLogger.new

      Timecop.freeze(Time.parse("2014-01-01 1:0:1"))
      logger.log_duration("stream")

      Timecop.freeze(Time.parse("2014-01-01 2:0:0"))
      logger = MetricsLogger.new

      Timecop.freeze(Time.parse("2014-01-01 2:0:2"))
      logger.log_duration("stream")

      expect(MetricsLogger.queue).to eq({"stream.duration" => [1000, 2000]})
    end
  end

  describe ".log" do
    it "logs correct values" do
      MetricsLogger.log('stream', lag: 100, other: 200)
      MetricsLogger.log('stream', lag: 200, other: 400)

      expect(MetricsLogger.queue).to eq({
        "stream.lag" => [100, 200],
        "stream.other" => [200, 400]
      })

    end
  end

  describe ".log_duration" do
    it "logs correct values" do
      MetricsLogger.log_duration "stream" do
        sleep 0.1
      end

      expect(MetricsLogger.queue["stream.duration"][0]).to be_within(5).of(100)
    end
  end

  describe ".sync" do
    before do
      Timecop.freeze(Time.parse("2014-01-01 1:0:0"))
      MetricsLogger.configure do |config|
        config.app_name = "test"
        config.tags = {host: "hostname", env: "production"}
      end
    end

    it "sends correct api call" do
      MetricsLogger.log('stream', lag: 100, other: 200)
      MetricsLogger.log('stream', lag: 200, other: 400)
      MetricsLogger.log('stream', lag: 300, other: 600)

      test_object = {a: 1, b: 2}
      MetricsLogger.sample("queue_size", object: test_object, method: "size")

      expected_data = [
        {metric: "test.stream.lag.total",     timestamp: 1388566800000, value: 600,   tags: {host: "hostname", env: "production"}},
        {metric: "test.stream.lag.count",     timestamp: 1388566800000, value: 3,     tags: {host: "hostname", env: "production"}},
        {metric: "test.stream.lag.average",   timestamp: 1388566800000, value: 200.0, tags: {host: "hostname", env: "production"}},
        {metric: "test.stream.other.total",   timestamp: 1388566800000, value: 1200,  tags: {host: "hostname", env: "production"}},
        {metric: "test.stream.other.count",   timestamp: 1388566800000, value: 3,     tags: {host: "hostname", env: "production"}},
        {metric: "test.stream.other.average", timestamp: 1388566800000, value: 400.0, tags: {host: "hostname", env: "production"}},
        {metric: "test.queue_size",           timestamp: 1388566800000, value: 2,     tags: {host: "hostname", env: "production"}}
      ]

      expect(Faraday).to receive(:post).with(MetricsLogger.configuration.endpoint, expected_data.to_json)

      MetricsLogger.sync
    end
  end

  describe ".sample" do
    it "adds to sampling_definitions correctly" do
      object = {test: "test", test2: "test"}
      MetricsLogger.sample("test", object: object, method: "size")
      expect(MetricsLogger.sampling_definitions).to eq([{name: "test", object: object, method: "size"}])
    end
  end
end
