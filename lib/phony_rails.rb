require 'phony'
require 'iso3166'
require 'phony_rails/string_extensions'
require 'validators/phony_validator'
require 'phony_rails/version'

module PhonyRails

  def self.country_number_for(country_code)
    ISO3166::Country::Data[country_code].try(:[], 'country_code')
  end

  # This method requires a country_code attribute (eg. NL) and phone_number to be set.
  # Options:
  #   :country_number => The country dial code (eg. 31 for NL).
  #   :default_country_number => Fallback country code.
  #   :country_code => The country code we should use.
  #   :default_country_code => Some fallback code (eg. 'NL') that can be used as default (comes from phony_normalize_numbers method).
  # This idea came from:
  #   http://www.redguava.com.au/2011/06/rails-convert-phone-numbers-to-international-format-for-sms/
  def self.normalize_number(number, options = {})
    return if number.nil?
    number = number.clone # Just to be sure, we don't want to change the original.
    number.gsub!(/[^\d\+]/, '') # Strips weird stuff from the number
    return if number.blank?
    if country_number = options[:country_number] || country_number_for(options[:country_code])
      # (Force) add country_number if missing
      number = "#{country_number}#{number}" if not number =~ /^(00|\+)?#{country_number}/
    elsif default_country_number = options[:default_country_number] || country_number_for(options[:default_country_code])
      # Add default_country_number if missing
      number = "#{default_country_number}#{number}" if not number =~ /^(00|\+|#{default_country_number})/
    end
    number = Phony.normalize(number) if Phony.plausible?(number)
    return number.to_s
  rescue
    number # If all goes wrong .. we still return the original input.
  end

  module Extension
    extend ActiveSupport::Concern

    included do
      private

      # This methods sets the attribute to the normalized version.
      # It also adds the country_code (number), eg. 31 for NL numbers.
      def set_phony_normalized_numbers(attributes, options = {})
        options = options.clone
        options[:country_code] ||= self.country_code if self.respond_to?(:country_code)
        attributes.each do |attribute|
          attribute_name = options[:as] || attribute
          raise RuntimeError, "No attribute #{attribute_name} found on #{self.class.name} (PhonyRails)" if not self.class.attribute_method?(attribute_name)
          write_attribute(attribute_name, PhonyRails.normalize_number(read_attribute(attribute), options))
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
        options.assert_valid_keys :country_code, :default_country_code, :as
        if options[:as].present?
          raise ArgumentError, ':as option can not be used on phony_normalize with multiple attribute names! (PhonyRails)' if attributes.size > 1
          raise ArgumentError, "'#{options[:as]}' is not an attribute on #{self.name}. You might want to use 'phony_normalized_method :#{attributes.first}' (PhonyRails)" if not self.attribute_method?(options[:as])
        end
        # Add before validation that saves a normalized version of the phone number
        self.before_validation do
          set_phony_normalized_numbers(attributes, options)
        end
      end

      # Usage:
      #   phony_normalized_method :fax_number, :default_country_code => 'US'
      # Creates a normalized_fax_number method.
      def phony_normalized_method(*attributes)
        main_options = attributes.last.is_a?(Hash) ? attributes.pop : {}
        main_options.assert_valid_keys :country_code, :default_country_code
        attributes.each do |attribute|
          raise StandardError, "Instance method normalized_#{attribute} already exists on #{self.name} (PhonyRails)" if method_defined?(:"normalized_#{attribute}")
          define_method :"normalized_#{attribute}" do |*args|
            options = args.first || {}
            raise ArgumentError, "No attribute/method #{attribute} found on #{self.class.name} (PhonyRails)" if not self.respond_to?(attribute)
            options[:country_code] ||= self.country_code if self.respond_to?(:country_code)
            PhonyRails.normalize_number(self.send(attribute), main_options.merge(options))
          end
        end
      end
    end
  end
end

# check whether it is ActiveRecord or Mongoid being used
ActiveRecord::Base.send :include, PhonyRails::Extension if defined?(ActiveRecord)

if defined?(Mongoid)
  module Mongoid::Phony
    extend ActiveSupport::Concern
    include PhonyRails::Extension
  end
end

Dir["#{File.dirname(__FILE__)}/phony_rails/locales/*.yml"].each do |file|
  I18n.load_path << file
end
