# Uses the Phony.plausible method to validate an attribute.
# Usage:
#   validate :phone_number, :phony_plausible => true
class PhonyPlausibleValidator < ActiveModel::EachValidator

  # Validates a String using Phony.plausible? method.
  def validate_each(record, attribute, value)
    return if value.blank?

    @record = record
    @record.errors.add(attribute, error_message) if not Phony.plausible?(value, cc: country_code_or_country_number)
  end

  private

  def error_message
    options[:message] || :improbable_phone
  end

  def country_code_or_country_number
    options[:country_code] || record_country_number || record_country_code
  end

  def record_country_number
    @record.country_number if @record.respond_to?(:country_number)
  end

  def record_country_code
    @record.country_code if @record.respond_to?(:country_code)
  end

end

module ActiveModel
  module Validations
    module HelperMethods

      def validates_plausible_phone(*attr_names)
        # merged attributes are modified somewhere, so we are cloning them for each validator
        merged_attributes = _merge_attributes(attr_names)

        validates_with ActiveRecord::Validations::UniquenessValidator, merged_attributes.clone if merged_attributes[:uniqueness]
        validates_with PresenceValidator, merged_attributes.clone if merged_attributes[:presence]
        validates_with FormatValidator, merged_attributes.clone if (merged_attributes[:with] or merged_attributes[:without])
        validates_with PhonyPlausibleValidator, merged_attributes.clone
      end

    end
  end
end
