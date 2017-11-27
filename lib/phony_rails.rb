# frozen_string_literal: true

require 'phony'
require 'phony_rails/string_extensions'
require 'validators/phony_validator'
require 'phony_rails/version'
require 'yaml'

module PhonyRails
  def self.default_country_code
    @default_country_code ||= nil
  end

  def self.default_country_code=(new_code)
    @default_country_code = new_code
    @default_country_number = nil # Reset default country number, will lookup next time its asked for
  end

  def self.default_country_number
    @default_country_number ||= default_country_code.present? ? country_number_for(default_country_code) : nil
  end

  def self.default_country_number=(new_number)
    @default_country_number = new_number
  end

  def self.country_number_for(country_code)
    return if country_code.nil?

    country_codes_hash.fetch(country_code.to_s.upcase, {})['country_code']
  end

  def self.country_codes_hash
    @country_codes_hash ||= YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'data/country_codes.yaml'))
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
    original_number = number
    number = number.dup # Just to be sure, we don't want to change the original.
    number, ext = extract_extension(number)
    number.gsub!(/[^\(\)\d\+]/, '') # Strips weird stuff from the number
    return if number.blank?
    if _country_number = options[:country_number] || country_number_for(options[:country_code])
      options[:add_plus] = true if options[:add_plus].nil?
      # (Force) add country_number if missing
      # NOTE: do we need to force adding country code? Otherwise we can share logic with next block
      if !Phony.plausible?(number) || _country_number != country_code_from_number(number)
        number = "#{_country_number}#{number}"
      end
    elsif _default_country_number = extract_default_country_number(options)
      options[:add_plus] = true if options[:add_plus].nil?
      number = normalize_number_default_country(number, _default_country_number)
    end
    normalized_number = Phony.normalize(number)
    options[:add_plus] = true if options[:add_plus].nil? && Phony.plausible?(normalized_number)
    normalized_number = options[:add_plus] ? "+#{normalized_number}" : normalized_number
    format_extension(normalized_number, ext)
  rescue StandardError
    original_number # If all goes wrong .. we still return the original input.
  end

  def self.normalize_number_default_country(number, default_country_number)
    # We try to add the default country number and see if it is a
    # correct phone number. See https://github.com/joost/phony_rails/issues/87#issuecomment-89324426
    unless number =~ /\A\+/ # if we don't have a +
      return "#{default_country_number}#{number}" if Phony.plausible?("#{default_country_number}#{number}") || !Phony.plausible?(number) || country_code_from_number(number).nil?
      # If the number starts with ONE zero (two might indicate a country code)
      # and this is a plausible number for the default_country
      # we prefer that one.
      return "#{default_country_number}#{number.gsub(/^0/, '')}" if (number =~ /^0[^0]/) && Phony.plausible?("#{default_country_number}#{number.gsub(/^0/, '')}")
    end
    # number = "#{default_country_number}#{number}" unless Phony.plausible?(number)
    # Just return the number unchanged
    number
  end

  def self.extract_default_country_number(options = {})
    options[:default_country_number] || country_number_for(options[:default_country_code]) || default_country_number
  end

  def self.country_code_from_number(number)
    return nil unless Phony.plausible?(number)
    Phony.split(Phony.normalize(number)).first
  end

  # Wrapper for Phony.plausible?.  Takes the same options as #normalize_number.
  # NB: This method calls #normalize_number and passes _options_ directly to that method.
  def self.plausible_number?(number, options = {})
    return false if number.blank?
    number = extract_extension(number).first
    number = normalize_number(number, options)
    country_number = options[:country_number] || country_number_for(options[:country_code]) ||
                     options[:default_country_number] || country_number_for(options[:default_country_code]) ||
                     default_country_number
    Phony.plausible? number, cc: country_number
  rescue StandardError
    false
  end

  COMMON_EXTENSIONS = /[ ]*(ext|ex|x|xt|#|:)+[^0-9]*\(?([-0-9]{1,})\)?#?$/i

  def self.extract_extension(number_and_ext)
    return [nil, nil] if number_and_ext.nil?
    subbed = number_and_ext.sub(COMMON_EXTENSIONS, '')
    [subbed, Regexp.last_match(2)]
  end

  def self.format_extension(number, ext)
    ext.present? ? "#{number} x#{ext}" : number
  end

  module Extension
    extend ActiveSupport::Concern

    included do
      private

      # This methods sets the attribute to the normalized version.
      # It also adds the country_code (number), eg. 31 for NL numbers.
      def set_phony_normalized_numbers(attributes, options = {})
        options = options.dup
        assign_values_for_phony_symbol_options(options)
        if respond_to?(:country_code)
          set_country_as = options[:enforce_record_country] ? :country_code : :default_country_code
          options[set_country_as] ||= country_code
        end
        attributes.each do |attribute|
          attribute_name = options[:as] || attribute
          raise("No attribute #{attribute_name} found on #{self.class.name} (PhonyRails)") unless self.class.attribute_method?(attribute_name)
          new_value = PhonyRails.normalize_number(send(attribute), options)
          send("#{attribute_name}=", new_value) if new_value || attribute_name != attribute
        end
      end

      def assign_values_for_phony_symbol_options(options)
        symbol_options = %i[country_number default_country_number country_code default_country_code]
        symbol_options.each do |option|
          options[option] = send(options[option]) if options[option].is_a?(Symbol)
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
        options.assert_valid_keys :country_number, :default_country_number, :country_code, :default_country_code, :add_plus, :as, :enforce_record_country, :if, :unless
        if options[:as].present?
          raise ArgumentError, ':as option can not be used on phony_normalize with multiple attribute names! (PhonyRails)' if attributes.size > 1
        end

        options[:enforce_record_country] = true if options[:enforce_record_country].nil?

        conditional = create_before_validation_conditional_hash(options)

        # Add before validation that saves a normalized version of the phone number
        before_validation conditional do
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
          raise(StandardError, "Instance method normalized_#{attribute} already exists on #{name} (PhonyRails)") if method_defined?(:"normalized_#{attribute}")
          define_method :"normalized_#{attribute}" do |*args|
            options = main_options.merge(args.first || {})
            assign_values_for_phony_symbol_options(options)
            raise(ArgumentError, "No attribute/method #{attribute} found on #{self.class.name} (PhonyRails)") unless respond_to?(attribute)
            options[:country_code] ||= country_code if respond_to?(:country_code)
            PhonyRails.normalize_number(send(attribute), options)
          end
        end
      end

      private

      # Creates a hash representing a conditional for before_validation
      # This allows conditional normalization
      # Returns something like `{ unless: -> { attribute == 'something' } }`
      # If no if/unless options passed in, returns `{ if: -> { true } }`
      def create_before_validation_conditional_hash(options)
        if options[:if].present?
          type = :if
          source = options[:if]
        elsif options[:unless].present?
          type = :unless
          source = options[:unless]
        else
          type = :if
          source = true
        end

        conditional = {}
        conditional[type] = if source.respond_to?(:call)
                              source
                            elsif source.respond_to?(:to_sym)
                              -> { send(source.to_sym) }
                            else
                              -> { source }
                            end
        conditional
      end
    end
  end
end

# check whether it is ActiveRecord or Mongoid being used
if defined?(ActiveRecord)
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.send :include, PhonyRails::Extension
  end
end

ActiveModel::Model.send :include, PhonyRails::Extension if defined?(ActiveModel::Model)

if defined?(Mongoid)
  module Mongoid::Phony
    extend ActiveSupport::Concern
    include PhonyRails::Extension
  end
end

Dir["#{File.dirname(__FILE__)}/phony_rails/locales/*.yml"].each do |file|
  I18n.load_path << file
end
