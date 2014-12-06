source 'https://rubygems.org'

# Preempt the default loading so that we don't get an unqualified Country class imported.
gem 'countries', :require => 'iso3166'

gemspec # Specify your gem's dependencies in phony_number.gemspec

# For testing
gem 'sqlite3'

gem 'rake'
gem 'rspec',          '~> 2.14.0'
gem 'guard',          '~> 2.10.1'
gem 'guard-bundler',  '~> 2.0.0'
gem 'guard-rspec',    '~> 4.2.0'

case RbConfig::CONFIG['host_os']
  when /darwin/i
    gem 'growl'
    gem 'rb-fsevent'
  when /linux/i
    gem 'libnotify'
    gem 'rb-inotify'
  when /mswin|windows/i
    gem 'rb-fchange'
    gem 'rb-notifu'
    gem 'win32console'
end

