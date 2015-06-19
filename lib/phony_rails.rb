require 'phony'
require 'iso3166'
require 'phony_rails/string_extensions'
require 'validators/phony_validator'
require 'phony_rails/version'

module PhonyRails

  def self.country_number_for(country_code)
    ISO3166::Country::Data[country_code.to_s.upcase].try(:[], 'country_code')
  end

  # This method requires a country_code attribute (eg. NL) and phone_number to be set.
  # Options:
  #   :country_number => The country dial code (eg. 31 for NL).
  #   :default_country_number => Fallback country code.
  #   :country_code => The country code we should use.
  #   :default_country_code => Some fallback code (eg. 'NL') that can be used as default (comes from phony_normalize_numbers method).
  #   :add_plus => Add a '+' in front so we know the country code is added. (default: true)
  # This idea came from:
  #   http://www.redguava.com.au/2011/06/rails-convert-phone-numbers-to-international-format-for-sms/
  def self.normalize_number(number, options = {})
    return if number.nil?
    number = number.clone # Just to be sure, we don't want to change the original.
    number.gsub!(/[^\(\)\d\+]/, '') # Strips weird stuff from the number
    return if number.blank?
    if _country_number = options[:country_number] || country_number_for(options[:country_code])
      options[:add_plus] = true if options[:add_plus].nil?
      # (Force) add country_number if missing
      # NOTE: do we need to force adding country code? Otherwise we can share lofic with next block
      if !Phony.plausible?(number) || _country_number != country_code_from_number(number)
        number = "#{_country_number}#{number}"
      end
    elsif _default_country_number = options[:default_country_number] || country_number_for(options[:default_country_code])
      options[:add_plus] = true if options[:add_plus].nil?
      # We try to add the default country number and see if it is a
      # correct phone number. See https://github.com/joost/phony_rails/issues/87#issuecomment-89324426
      if not (number =~ /\A\+/) # if we don't have a +
        if Phony.plausible?("#{_default_country_number}#{number}") || !Phony.plausible?(number) || country_code_from_number(number).nil?
          number = "#{_default_country_number}#{number}"
        end
      end
      # number = "#{_default_country_number}#{number}" unless Phony.plausible?(number)
    end
    normalized_number = Phony.normalize(number)
    options[:add_plus] = true if options[:add_plus].nil? && Phony.plausible?(normalized_number)
    options[:add_plus] ? "+#{normalized_number}" : normalized_number
  rescue
    number # If all goes wrong .. we still return the original input.
  end

  def self.country_code_from_number(number)
    return nil unless Phony.plausible?(number)
    Phony.split(Phony.normalize(number)).first
  end

  # Wrapper for Phony.plausible?.  Takes the same options as #normalize_number.
  # NB: This method calls #normalize_number and passes _options_ directly to that method.
  def self.plausible_number?(number, options = {})
    return false if number.nil? || number.blank?
    number = normalize_number(number, options)
    country_number = options[:country_number] || country_number_for(options[:country_code]) || 
      default_country_number = options[:default_country_number] || country_number_for(options[:default_country_code])
    Phony.plausible? number, cc: country_number
  rescue
    false
  end

  module Extension
    extend ActiveSupport::Concern

    included do
      private

      # This methods sets the attribute to the normalized version.
      # It also adds the country_code (number), eg. 31 for NL numbers.
      def set_phony_normalized_numbers(attributes, options = {})
        options = options.clone
        if self.respond_to?(:country_code)
          set_country_as = options[:enforce_record_country] ? :country_code : :default_country_code
          options[set_country_as] ||= self.country_code
        end
        attributes.each do |attribute|
          attribute_name = options[:as] || attribute
          raise RuntimeError, "No attribute #{attribute_name} found on #{self.class.name} (PhonyRails)" if not self.class.attribute_method?(attribute_name)
          self.send("#{attribute_name}=", PhonyRails.normalize_number(self.send(attribute), options))
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
        options.assert_valid_keys :country_number, :default_country_number, :country_code, :default_country_code, :add_plus, :as, :enforce_record_country
        if options[:as].present?
          raise ArgumentError, ':as option can not be used on phony_normalize with multiple attribute names! (PhonyRails)' if attributes.size > 1
        end

        options[:enforce_record_country] = true if options[:enforce_record_country].nil?

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
