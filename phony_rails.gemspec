# -*- encoding: utf-8 -*-
require File.expand_path('../lib/phony_rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joost Hietbrink"]
  gem.email         = ["joost@joopp.com"]
  gem.description   = %q{This Gem adds useful methods to your Rails app to validate, display and save phone numbers.}
  gem.summary       = %q{This Gem adds useful methods to your Rails app to validate, display and save phone numbers.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "phony_rails"
  gem.require_paths = ["lib"]
  gem.version       = PhonyRails::VERSION

  gem.add_dependency "phony", "~> 1.7.4"
  gem.add_dependency "activerecord", "~> 3.0"
end
