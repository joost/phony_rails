# -*- encoding: utf-8 -*-
require File.expand_path('../lib/phony_number/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joost Hietbrink"]
  gem.email         = ["joost@joopp.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "phony_number"
  gem.require_paths = ["lib"]
  gem.version       = PhonyNumber::VERSION

  gem.add_dependency "phony", "~> 1.6.7"
  gem.add_dependency "activerecord", "~> 3.0"
end
