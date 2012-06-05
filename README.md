# PhonyRails

(In its early days :) called PhonyNumber)

This Gem adds useful methods to your Rails app to validate, display and save phone numbers.
It uses the super awesome Phony gem (https://github.com/floere/phony).

## Installation

Add this line to your application's Gemfile:

    gem 'phony_rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install phony_rails

## Usage

In your model add:

    class SomeModel < ActiveRecord::Base
      phony_normalize :phone_number, :default_country_code => 'US' # Normalizes the attribute itself
      phony_normalized_method :fax_number # Creates method normalized_fax_number that returns the normalized version of fax_number
    end

The `:default_country_code` options is used to specify a country_code when normalizing.

PhonyRails will also check your model for a country_code method to use when normalizing the number. So `'070-12341234'` with `country_code` 'NL' will get normalized to `'317012341234'`.

Use the Phony.plausible method to validate an attribute:

    validate :phone_number, :phony_plausible => true

In your views use:

    <%= "some number string variable".phony_formatted(:format => :international, :spaces => '-') %>

## Changelog

0.0.9
* Fix for using same options Hash for all models.

0.0.8
* Improved number cleaning not to remove '+' and leading 0's. Now works with national numbers starting with 0 followed by country_code. Eg. 032 in BE.

0.0.7
* Fixed problem with '+' number

0.0.6
* Fixed problem with '070-4157134' being parsed as US number

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
