# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zed/version'

Gem::Specification.new do |spec|
  spec.name          = "zed"
  spec.version       = Zed::VERSION
  spec.authors       = ["Andre Lewis"]
  spec.email         = ["andre@scoutapp.com"]
  spec.description   = "Standalone realtime proof-of-concept"
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = "zed" #spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
