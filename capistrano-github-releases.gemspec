# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/github/releases/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-github-releases"
  spec.version       = Capistrano::Github::Releases::VERSION
  spec.authors       = ["linyows"]
  spec.email         = ["linyows@gmail.com"]
  spec.summary       = %q{GitHub Releases tasks for Capistrano v3}
  spec.description   = %q{GitHub Releases tasks for Capistrano v3}
  spec.homepage      = "https://github.com/linyows/capistrano-github-releases"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", ">= 3.1"
  spec.add_dependency "octokit", ">= 3.1.0"
  spec.add_dependency "highline", ">= 1.6.20"
  spec.add_dependency "dotenv", ">= 0.11.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake"
end
