require 'phony'
require "phony_number/string_extensions"
require "phony_number/version"

module PhonyNumber

  # Quick fix to get country_phone_number (phone number) for all relevant countries.
  # TODO: Replace with some gem or something.
  COUNTRY_NUMBER = {
    'NL' => '31',
    'BE' => '32',
    'DE' => '49',
    'GB' => '44',
    'FR' => '33',
    'ES' => '34',
    'IT' => '39',
    'US' => '1',
    'AU' => '61',
    'LU' => '352'
  }

  # This method requires a country_code attribute (eg. NL) and phone_number to be set.
  # Options:
  #   :country_code => Some code that can be used as default.
  def self.normalize_number(number, options = {})
    return if number.blank?
    number = Phony.normalize(number) # TODO: Catch errors
    if country_number = COUNTRY_NUMBER[options[:country_code] || options[:default_country_code]]
      # Add country_number if missing
      number = "#{country_number}#{number}" not number =~ /^(00|\+)?#{country_number}/
    end
    number = Phony.normalize(number)
  rescue
    number # If all goes wrong .. we still return the original input.
  end

  # This module is added to AR.
  module ActiveRecordExtension

    def self.extended(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
  
    private

      # This methods sets the attribute to the normalized version.
      # It also adds the country_code (number), eg. 31 for NL numbers.
      def set_phony_normalized_numbers(attributes, options = {})
        options[:country_code] ||= self.country_code if self.respond_to?(:country_code)
        attributes.each do |attribute|
          write_attribute(attribute, PhonyNumber.normalize_number(read_attribute(attribute), options))
        end
      end

    end

    module ClassMethods

      # Use this method on the class level like:
      #   phony_normalize_numbers :phone_number, :fax_number, :default_country_code => 'NL'
      #
      # It checks your model object for a a country_code attribute (eg. 'NL') to do the normalizing so make sure
      # you've geocoded before calling this method!
      def phony_normalize_numbers(*attributes)
        options = attributes.last.is_a?(Hash) ? attributes.last : {}
        attributes.each do |attribute|
          # Add before validation that saves a normalized version of the phone number
          self.before_validation do 
            set_phony_normalized_numbers(attributes, options)
          end
        end
      end

    end

  end

end
ActiveRecord::Base.extend PhonyNumber::ActiveRecordExtension