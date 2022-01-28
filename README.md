# PhonyRails [![Build Status](https://travis-ci.org/joost/phony_rails.svg?branch=master)](https://travis-ci.org/joost/phony_rails) [![Coverage Status](https://coveralls.io/repos/joost/phony_rails/badge.svg)](https://coveralls.io/r/joost/phony_rails) ![Dependencies Status](https://img.shields.io/gem/v/phony_rails.svg)

This small Gem adds useful methods to your Rails app to validate, display and save phone numbers.
It uses the super awesome Phony gem (https://github.com/floere/phony).

Find version information in the [CHANGELOG](CHANGELOG.md).

## Installation

Add this line to your application's Gemfile (requires Ruby > 2.3):

```ruby
gem 'phony_rails'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install phony_rails
```

## Usage

### Normalization / Model Usage

#### ActiveRecord

For **ActiveRecord**, in your model add:

```ruby
class SomeModel < ActiveRecord::Base
  # Normalizes the attribute itself before validation
  phony_normalize :phone_number, default_country_code: 'US'

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone_number, as: :phone_number_normalized_version, default_country_code: 'US'

  # Creates method normalized_fax_number that returns the normalized version of fax_number
  phony_normalized_method :fax_number

  # Conditionally normalizes the attribute
  phony_normalize :recipient, default_country_code: 'US', if: -> { contact_method == 'phone_number' }
end
```

#### ActiveModel (models without database)

For Rails-like models without a database, add:

```ruby
class SomeModel
  include ActiveModel::Model # we get AR-like attributes and validations
  include ActiveModel::Validations::Callbacks # a dependency for normalization

  # your attributes must be defined, they are not inherited from a DB table
  attr_accessor :phone_number, :phone_number_as_normalized

  # Once the model is set up, we have the same things as with ActiveRecord
  phony_normalize :phone_number, default_country_code: 'US'
end
```

#### Mongoid (DEPRECATED)

WARNING: From v0.15.0 Mongoid support has been removed!

#### General info

The `:default_country_code` options is used to specify a country_code when normalizing.

PhonyRails will also check your model for a country_code method to use when normalizing the number. So `'070-12341234'` with `country_code` 'NL' will get normalized to `'+317012341234'`.

You can also do-it-yourself and call:

```ruby
# Options:
#   :country_code => The country code we should use (forced).
#   :default_country_code => Some fallback code (eg. 'NL') that can be used as default (comes from phony_normalize_numbers method).

PhonyRails.normalize_number('some number', country_code: 'NL')

PhonyRails.normalize_number('+4790909090', country_code: 'SE') # => '+464790909090' (forced to +46)
PhonyRails.normalize_number('+4790909090', default_country_code: 'SE') # => '+4790909090' (still +47 so not changed)
```

The country_code should always be a ISO 3166-1 alpha-2 (http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).

#### Default for all models

You can set the default_country_code for all models using:

```ruby
PhonyRails.default_country_code = "US"
```

### Validation

In your model use the Phony.plausible method to validate an attribute:

```ruby
validates :phone_number, phony_plausible: true
```

or the helper method:

```ruby
validates_plausible_phone :phone_number
```

this method use other validators under the hood to provide:

- presence validation using `ActiveModel::Validations::PresenceValidator`
- format validation using `ActiveModel::Validations::FormatValidator`

so we can use:

```ruby
validates_plausible_phone :phone_number, presence: true
validates_plausible_phone :phone_number, with: /\A\+\d+/
validates_plausible_phone :phone_number, without: /\A\+\d+/
validates_plausible_phone :phone_number, presence: true, with: /\A\+\d+/
```

the i18n key is `:improbable_phone`. Languages supported by default: de, en, es, fr, it, ja, kh, ko, nl, pt, tr, ua and ru.

You can also validate if a number has the correct country number:

```ruby
validates_plausible_phone :phone_number, country_number: '61'
```

or correct country code:

```ruby
validates_plausible_phone :phone_number, country_code: 'AU'
```

You can validate against the normalized input as opposed to the raw input:

```ruby
phony_normalize :phone_number, as: :phone_number_normalized, default_country_code: 'US'
validates_plausible_phone :phone_number_normalized, presence: true, if: :phone_number?
```

Validation supports phone numbers with extension, such as `+18181231234 x1234` or `'+1 (818)151-5483 #4312'` out-of-the-box.

Return original value after validation:

The flag normalize_when_valid (disabled by default), allows to return the original phone_number when is the object is not valid. When phone validation fails, normalization is not triggered at all. It could prevent a situation where user fills in the phone number and after validation, he gets back different, already normalized phone number value, even if phone number was wrong.

Example usage:

```ruby
validates_plausible_phone :phone_number
phony_normalize :phone_number, country_code: :country_code, normalize_when_valid: true
```

Filling in the number will result with following:

When the number is incorrect (e.g. phone_number: `+44 888 888 888` for country_code 'PL'), the original validation behavior is preserved, but if the number is still invalid, the original value is returned.
When number is valid, it will save the normalized number (e.g. `+48 888 888 888` will be saved as `+48888888888`).

#### Allowing records country codes to not match phone number country codes

You may have a record specifying one country (via a `country_code` attribute) but using a phone number from another country. For example, your record may be from Japan but have a phone number from the Philippines. By default, `phony_rails` will consider your record's `country_code` as part of the validation. If that country doesn't match the country code in the phone number, validation will fail.

Additionally, `phony_normalize` will always add the records country code as the country number (eg. the user enters '+81xxx' for Japan and the records `country_code` is 'DE' then `phony_normalize` will change the number to '+4981'). You can turn this off by adding `enforce_record_country: false` to the validation options. The country_code will then only be added if no country code is specified.

If you want to allow records from one country to have phone numbers from a different one, there are a couple of options you can use: `ignore_record_country_number` and `ignore_record_country_code`. Use them like so:

```ruby
validates :phone_number, phony_plausible: { ignore_record_country_code: true, ignore_record_country_number: true }
```

Obviously, you don't have to use both, and you may not need or want to set either.

### Display / Views

In your views use:

```erb
<%= "311012341234".phony_formatted(format: :international, spaces: '-') %>
<%= "+31-10-12341234".phony_formatted(format: :international, spaces: '-') %>
<%= "+31(0)1012341234".phony_formatted(format: :international, spaces: '-') %>
```

To first normalize the String to a certain country use:

```erb
<%= "010-12341234".phony_formatted(normalize: :NL, format: :international, spaces: '-') %>
```

To return nil when a number is not valid:

```ruby
"123".phony_formatted(strict: true) # => nil
```

You can also use the bang method (phony_formatted!):

```ruby
number = "010-12341234"
number.phony_formatted!(normalize: :NL, format: :international)
number # => "+31 10 123 41234"
```

You can also easily normalize a phone number String:

```ruby
"+31 (0)30 1234 123".phony_normalized # => '31301234123'
"(0)30 1234 123".phony_normalized # => '301234123'
"(0)30 1234 123".phony_normalized(country_code: 'NL') # => '301234123'
```

Extensions are supported (identified by "ext", "ex", "x", "xt", "#", or ":") and will show at the end of the number:

```ruby
"+31 (0)30 1234 123 x999".phony_normalized # => '31301234123 x999'
"+31 (0)30 1234 123 ext999".phony_normalized # => '31301234123 x999'
"+31 (0)30 1234 123 #999".phony_normalized # => '31301234123 x999'
```

### Find by normalized number

Say you want to find a record by a phone number. Best is to normalize user input and compare to an attribute stored in the db.

```ruby
Home.find_by_normalized_phone_number(PhonyRails.normalize_number(params[:phone_number]))
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Don't forget to add tests and run rspec before creating a pull request :)

See all contributors on https://github.com/joost/phony_rails/graphs/contributors.
