# Uses the Phony.plausible method to validate an attribute.
# Usage:
#   validate :phone_number, :phony_plausible => true
require 'active_model'
class PhonyPlausibleValidator < ActiveModel::EachValidator
  # Validates a String using Phony.plausible? method.
  def validate_each(record, attribute, value)
    return if value.blank?

    @record = record
    value = PhonyRails.normalize_number(value.dup, default_country_code: normalized_country_code) if normalized_country_code
    @record.errors.add(attribute, error_message) unless Phony.plausible?(value, cc: country_number)
  end

  private

  def error_message
    options_value(:message) || :improbable_phone
  end

  def country_number
    options_value(:country_number) || record_country_number || country_number_from_country_code
  end

  def record_country_number
    @record.country_number if @record.respond_to?(:country_number) && !options_value(:ignore_record_country_number)
  end

  def country_number_from_country_code
    PhonyRails.country_number_for(country_code)
  end

  def country_code
    options_value(:country_code) || record_country_code
  end

  def record_country_code
    @record.country_code if @record.respond_to?(:country_code) && !options_value(:ignore_record_country_code)
  end

  def normalized_country_code
    options_value(:normalized_country_code)
  end

  def options_value(option)
    if options[option].is_a?(Symbol)
      @record.send(options[option])
    else
      options[option]
    end
  end
end

module ActiveModel
  module Validations
    module HelperMethods
      def validates_plausible_phone(*attr_names)
        # merged attributes are modified somewhere, so we are cloning them for each validator
        merged_attributes = _merge_attributes(attr_names)

        validates_with PresenceValidator, merged_attributes.dup if merged_attributes[:presence]
        validates_with FormatValidator, merged_attributes.dup if merged_attributes[:with] || merged_attributes[:without]
        validates_with PhonyPlausibleValidator, merged_attributes.dup
      end
    end
  end
end
