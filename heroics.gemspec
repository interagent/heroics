# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'heroics/version'

Gem::Specification.new do |spec|
  spec.name          = "heroics"
  spec.version       = Heroics::VERSION
  spec.authors       = ["geemus"]
  spec.email         = ["geemus@gmail.com"]
  spec.description   = %q{Heroku API Ruby Client}
  spec.summary       = %q{Heroku API Ruby Client}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"

  spec.add_dependency "excon"
end
