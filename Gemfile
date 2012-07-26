source :rubygems
gemspec # Specify your gem's dependencies in phony_number.gemspec

# For testing
gem 'sqlite3'

gem 'rspec',          '~> 2.11.0'
gem 'guard',          '~> 1.2.0'
gem 'guard-bundler',  '~> 1.0.0'
gem 'guard-rspec',    '~> 1.2.0'

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

