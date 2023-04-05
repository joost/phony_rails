# frozen_string_literal: true

require File.expand_path('lib/phony_rails/version', __dir__)

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
  gem.required_ruby_version = '>= 2.4'

  gem.add_runtime_dependency 'activesupport', '>= 3.0'
  gem.add_runtime_dependency 'phony', '>= 2.18.12'
  gem.add_development_dependency 'activerecord', '>= 3.0'

  # For testing
  gem.add_development_dependency 'sqlite3', '>= 1.4.0'
end
