require "debugger"
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

module PhonyHelperMethods

  include ActiveRecord
  include ActiveModel

  def validates_plausible_phone(*attr_names)
    # merged attributes are modified somewhere, so we are cloning them for each validator
    merged_attributes = _merge_attributes(attr_names)

    #validate with each ActiveRecord/Model validator.
    #untested
    validates_with ActiveModel::Validations::AbsenceValidator, merged_attributes.clone if merged_attributes[:absence]
    validates_with ActiveModel::Validations::AcceptanceValidator, merged_attributes.clone if merged_attributes[:acceptance]
    validates_with ActiveModel::Validations::ConfirmationValidator, merged_attributes.clone if merged_attributes[:confirmation]
    validates_with ActiveModel::Validations::ExclusionValidator, merged_attributes.clone if merged_attributes[:exclusion]
    validates_with ActiveModel::Validations::InclusionValidator, merged_attributes.clone if merged_attributes[:inclusion]
    validates_with ActiveModel::Validations::LengthValidator, merged_attributes.clone if merged_attributes[:length]
    validates_with ActiveModel::Validations::NumericalityValidator, merged_attributes.clone if merged_attributes[:numericality]
    validates_with ActiveRecord::Validations::AssociatedValidator, merged_attributes.clone if merged_attributes[:associated]

    #tested
    validates_with ActiveModel::Validations::PresenceValidator, merged_attributes.clone if merged_attributes[:presence]
    validates_with ActiveRecord::Validations::UniquenessValidator, merged_attributes.clone if merged_attributes[:uniqueness]
    validates_with ActiveModel::Validations::FormatValidator, merged_attributes.clone if (merged_attributes[:with] || merged_attributes[:without])

    validates_with PhonyPlausibleValidator, merged_attributes.clone
  end

end

module ActiveModel
  module Validations
    module HelperMethods
      include PhonyHelperMethods
    end
  end
end

module ActiveRecord
  module Validations
    module HelperMethods
      include PhonyHelperMethods
    end
  end
end
