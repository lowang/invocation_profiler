# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'invocation_profiler/version'

Gem::Specification.new do |spec|
  spec.name          = "invocation_profiler"
  spec.version       = InvocationProfiler::VERSION
  spec.authors       = ["Przemysław Wróblewski"]
  spec.email         = ["przemyslaw.wroblewski@gmail.com"]
  spec.summary       = %q{Poor's man profiling on class method invocations}
  spec.description   = %q{Simple class methods profiler working by wrapping original method with Benchmark.realtime}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
