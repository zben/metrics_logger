# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metrics_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "metrics_logger"
  spec.version       = MetricsLogger::VERSION
  spec.authors       = ["Ben Zhang"]
  spec.email         = ["benzhangpro@gmail.com"]
  spec.summary       = %q{sends application metrics to opentsdb database.}
  spec.description   = %q{sync with server asynchronusly in separate thread.}
  spec.homepage      = "http://github.com/zben/metrics_logger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3.2"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  spec.add_development_dependency "timecop", "~> 0.7.1"

  spec.add_runtime_dependency "faraday", "~> 0.9.0"
  spec.add_runtime_dependency "thread_safe", "~> 0.3.4"
  spec.add_runtime_dependency "json", "~> 1.8.1"
end
