# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitomator/version'

Gem::Specification.new do |spec|
  spec.name          = "gitomator"
  spec.version       = Gitomator::VERSION
  spec.authors       = ["Joey Freund"]
  spec.email         = ["joeyfreund@gmail.com"]

  spec.summary       = "Automation tools for Git repo  organizations."
  spec.homepage      = "https://github.com/gitomator/gitomator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency 'trollop', '~> 2.1', '>= 2.1.2'
  spec.add_runtime_dependency 'logger', '~> 1.2', '>= 1.2.8'

end
