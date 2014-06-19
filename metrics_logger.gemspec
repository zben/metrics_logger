# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metrics_logger/version'

Gem::Specification.new do |spec|
  spec.name          = "metrics_logger"
  spec.version       = MetricsLogger::VERSION
  spec.authors       = ["Ben Zhang"]
  spec.email         = ["bzhang@legendben.com"]
  spec.summary       = %q{sends application metrics to opentsdb database.}
  spec.description   = %q{sends application metrics to opentsdb database.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"

  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "thread_safe"
  spec.add_runtime_dependency "json"
end
