require "metrics_logger/version"
require "metrics_logger/configuration"
require "metrics_logger/metrics_logger"

module MetricsLogger
  def self.method_missing(method, *args, &block)
    MetricsLogger.send(method, *args, &block)
  end
end
