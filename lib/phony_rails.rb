require 'phony'
require "phony_rails/string_extensions"
require "phony_rails/version"

module PhonyRails

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
  #   :country_code => The country code we should use.
  #   :default_country_code => Some fallback code (eg. 'NL') that can be used as default (comes from phony_normalize_numbers method).
  def self.normalize_number(number, options = {})
    return if number.blank?
    number = Phony.normalize(number) # TODO: Catch errors
    if country_number = COUNTRY_NUMBER[options[:country_code] || options[:default_country_code]]
      # Add country_number if missing
      number = "#{country_number}#{number}" if not number =~ /^(00|\+)?#{country_number}/
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
          write_attribute(attribute, PhonyRails.normalize_number(read_attribute(attribute), options))
        end
      end

    end

    module ClassMethods

      # Use this method on the class level like:
      #   phony_normalize :phone_number, :fax_number, :default_country_code => 'NL'
      #
      # It checks your model object for a a country_code attribute (eg. 'NL') to do the normalizing so make sure
      # you've geocoded before calling this method!
      def phony_normalize(*attributes)
        options = attributes.last.is_a?(Hash) ? attributes.pop : {} 
        options.assert_valid_keys :country_code, :default_country_code
        attributes.each do |attribute|
          # Add before validation that saves a normalized version of the phone number
          self.before_validation do 
            set_phony_normalized_numbers(attributes, options)
          end
        end
      end

      # Usage:
      #   phony_normalized_method :fax_number, :default_country_code => 'US'
      # Creates a normalized_fax_number method.
      def phony_normalized_method(*attributes)
        options = attributes.last.is_a?(Hash) ? attributes.pop : {} 
        options.assert_valid_keys :country_code, :default_country_code
        attributes.each do |attribute|
          raise ArgumentError, "Attribute #{attribute} was not found on #{self.name} (PhonyRails)" unless self.attribute_method?(attribute)
          define_method :"normalized_#{attribute}" do
            options[:country_code] ||= self.country_code if self.respond_to?(:country_code)
            PhonyRails.normalize_number(self[attribute], options)
          end
        end
      end

    end

  end

end
ActiveRecord::Base.extend PhonyRails::ActiveRecordExtension