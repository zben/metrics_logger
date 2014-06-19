module MetricsLogger
  class Configuration
    attr_accessor :endpoint, :backup_endpoint, :sync_interval, :app_name, :tags

    def initialize
      @endpoint = nil
      @backup_endpoint = nil
      @sync_interval = 60
      @app_name = nil
      @tags = {}
    end
  end
end
