# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ncore/version'

Gem::Specification.new do |spec|
  spec.name          = "ncore"
  spec.version       = NCore::VERSION
  spec.authors       = ["Notioneer Team"]
  spec.email         = ["hello@notioneer.com"]
  spec.description   = %q{NCore - Ruby gem useful for building REST API clients}
  spec.summary       = %q{NCore - Gem for building REST API clients}
  spec.homepage      = 'https://notioneer.com/'
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activemodel', '>= 4.2', '< 6.2'
  spec.add_dependency 'excon', '~> 0.32'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
