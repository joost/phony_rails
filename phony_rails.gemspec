# frozen_string_literal: true

require File.expand_path('../lib/phony_rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Joost Hietbrink']
  gem.email         = ['joost@joopp.com']
  gem.description   = 'This Gem adds useful methods to your Rails app to validate, display and save phone numbers.'
  gem.summary       = 'This Gem adds useful methods to your Rails app to validate, display and save phone numbers.'
  gem.homepage      = 'https://github.com/joost/phony_rails'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'phony_rails'
  gem.require_paths = ['lib']
  gem.version       = PhonyRails::VERSION

  gem.post_install_message = 'PhonyRails v0.10.0 changes the way numbers are stored!'
  gem.post_install_message = "It now adds a '+' to the normalized number when it starts with a country number!"

  gem.add_runtime_dependency 'activesupport', '>= 3.0'
  gem.add_runtime_dependency 'phony', '> 2.15'
  gem.add_development_dependency 'activerecord', '>= 3.0'
  gem.add_development_dependency 'mongoid', '>= 3.0'
end
