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

### Normalization / ActiveRecord Extension

In your model add:

    class SomeModel < ActiveRecord::Base

      # Normalizes the attribute itself before 
      phony_normalize :phone_number, :default_country_code => 'US'validation

      # Normalizes attribute before validation and saves into other attribute
      phony_normalize :phone_number, :as => :phone_number_normalized_version, :default_country_code => 'US' 

      # Creates method normalized_fax_number that returns the normalized version of fax_number
      phony_normalized_method :fax_number
    end

The `:default_country_code` options is used to specify a country_code when normalizing.

PhonyRails will also check your model for a country_code method to use when normalizing the number. So `'070-12341234'` with `country_code` 'NL' will get normalized to `'317012341234'`.

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

### Display / Views

In your views use:

    <%= "some number string variable".phony_formatted(:format => :international, :spaces => '-') %>

### Find by normalized number

Say you want to find a record by a phone number. Best is to normalize user input and compare to an attribute stored in the db.

    Home.find_by_normalized_phone_number(PhonyRails.normalize_number(params[:phone_number]))

## Changelog

0.1.10
* Changes from henning-koch.
* Some pending fixes.

0.1.8
* Improved validation methods by ddidier.

0.1.6
* Added :as option to phony_normalize.

0.1.5
* some tests and a helper method by ddidier.

0.1.2
* Using countries gem as suggested by brutuscat.
* Fixes bugs mentioned by ddidier.

0.1.0
* Added specs.

0.0.10
* Same fix as 0.0.9 but for phony_formatted method.

0.0.9
* Fix for using same options Hash for all models.

0.0.8
* Improved number cleaning not to remove '+' and leading 0's. Now works with national numbers starting with 0 followed by country_code. Eg. 032 in BE.

0.0.7
* Fixed problem with '+' number

0.0.6
* Fixed problem with '070-4157134' being parsed as US number

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

Thanks to all contributors: ddidier, brutuscat, henning-koch.