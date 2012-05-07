# PhonyNumber

This Gem adds useful methods to your Rails app to validate, display and save phone numbers.
It uses the super awesome Phony gem (https://github.com/floere/phony).

## Installation

Add this line to your application's Gemfile:

    gem 'phony_number'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install phony_number

## Usage

In your model add:

    class SomeModel < ActiveRecord::Base
      phony_normalize :phone_number, :default_country_code => 'US' # Normalizes the attribute itself
      phony_normalized_method :fax_number # Creates method normalized_fax_number that returns the normalized version of fax_number
    end

Use the Phony.plausible method to validate an attribute:

    validate :phone_number, :phony_number => true

In your views use:

    <%= "some number string variable".phony_formatted(:format => :international, :spaces => '-') %>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
