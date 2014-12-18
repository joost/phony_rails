# PhonyRails

This small Gem adds useful methods to your Rails app to validate, display and save phone numbers.
It uses the super awesome Phony gem (https://github.com/floere/phony).

## Installation

Add this line to your application's Gemfile:

    gem 'phony_rails' # Include phony_rails after mongoid (if you use mongoid, see issue #66 on github).

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install phony_rails

## Usage

### Normalization / Model Usage

#### ActiveRecord

For **ActiveRecord**, in your model add:

    class SomeModel < ActiveRecord::Base
      # Normalizes the attribute itself before validation
      phony_normalize :phone_number, :default_country_code => 'US'

      # Normalizes attribute before validation and saves into other attribute
      phony_normalize :phone_number, :as => :phone_number_normalized_version, :default_country_code => 'US'

      # Creates method normalized_fax_number that returns the normalized version of fax_number
      phony_normalized_method :fax_number
    end

#### Mongoid

For **Mongoid**, in keeping with Mongoid plug-in conventions you must include the `Mongoid::Phony` module:

    class SomeModel
      include Mongoid::Document
      include Mongoid::Phony

      # methods are same as ActiveRecord usage
    end

#### General info

The `:default_country_code` options is used to specify a country_code when normalizing.

PhonyRails will also check your model for a country_code method to use when normalizing the number. So `'070-12341234'` with `country_code` 'NL' will get normalized to `'317012341234'`.

You can also do-it-yourself and call:

    # Options:
    #   :country_code => The country code we should use (forced).
    #   :default_country_code => Some fallback code (eg. 'NL') that can be used as default (comes from phony_normalize_numbers method).

    PhonyRails.normalize_number('some number', :country_code => 'NL')

    PhonyRails.normalize_number('+4790909090', :country_code => 'SE') # => '464790909090' (forced to +46)
    PhonyRails.normalize_number('+4790909090', :default_country_code => 'SE') # => '4790909090' (still +47 so not changed)

The country_code should always be a ISO 3166-1 alpha-2 (http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).

### Validation

In your model use the Phony.plausible method to validate an attribute:

    validates :phone_number, :phony_plausible => true

or the helper method:

    validates_plausible_phone :phone_number

this method use other validators under the hood to provide:
* presence validation using `ActiveModel::Validations::PresenceValidator`
* format validation using `ActiveModel::Validations::FormatValidator`

so we can use:

    validates_plausible_phone :phone_number, :presence => true
    validates_plausible_phone :phone_number, :with => /^\+\d+/
    validates_plausible_phone :phone_number, :without => /^\+\d+/
    validates_plausible_phone :phone_number, :presence => true, :with => /^\+\d+/

the i18n key is `:improbable_phone`

You can also validate if a number has the correct country number:

    validates_plausible_phone :phone_number, :country_number => '61'

or correct country code:

    validates_plausible_phone :phone_number, :country_code => 'AU'

You can validate against the normalized input as opposed to the raw input:

    phony_normalize :phone_number, as: :phone_number_normalized, :default_country_code => 'US'
    validates_plausible_phone :phone_number, :normalized_country_code => 'US'

### Display / Views

In your views use:

    <%= "311012341234".phony_formatted(:format => :international, :spaces => '-') %>
    <%= "+31-10-12341234".phony_formatted(:format => :international, :spaces => '-') %>
    <%= "+31(0)1012341234".phony_formatted(:format => :international, :spaces => '-') %>

To first normalize the String to a certain country use:

    <%= "010-12341234".phony_formatted(:normalize => :NL, :format => :international, :spaces => '-') %>

To return nil when a number is not valid:

    "123".phony_formatted(:strict => true) # => nil

You can also use the bang method (phony_formatted!):

    number = "010-12341234"
    number.phony_formatted!(:normalize => :NL, :format => :international)
    number # => "+31 10 123 41234"

You can also easily normalize a phone number String:

    "+31 (0)30 1234 123".phony_normalized # => '31301234123'
    "(0)30 1234 123".phony_normalized # => '301234123'
    "(0)30 1234 123".phony_normalized(country_code: 'NL') # => '301234123'

### Find by normalized number

Say you want to find a record by a phone number. Best is to normalize user input and compare to an attribute stored in the db.

    Home.find_by_normalized_phone_number(PhonyRails.normalize_number(params[:phone_number]))

## Changelog

0.8.2
* Added String#phony_normalized method

## TODO

* Make this work: Home.find_by_normalized_phone_number(Home.normalize_number(params[:phone_number]))
  So we use Home.normalize_number instead of PhonyRails.normalize_number. This way we can use the same default_country_code.
* Make country_code method configurable.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Don't forget to add tests and run rspec before creating a pull request :)

See all contributors on https://github.com/joost/phony_rails/graphs/contributors.
