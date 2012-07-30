# Uses the Phony.plausible method to validate an attribute.
# Usage:
#   validate :phone_number, :phony_plausible => true
class PhonyPlausibleValidator < ActiveModel::EachValidator

  # Validates a String using Phony.plausible? method.
  def validate_each(record, attribute, value)
    return if value.blank?
    record.errors.add(attribute,  options[:message] || :improbable_phone) if not Phony.plausible?(value)
  end

end

module ActiveModel
  module Validations
    module HelperMethods

      def validates_plausible_phone(*attr_names)
        # merged attributes are modified somewhere, so we are cloning them for each validator
        merged_attributes = _merge_attributes(attr_names)

        validates_with PresenceValidator, merged_attributes.clone if merged_attributes[:presence]
        validates_with FormatValidator, merged_attributes.clone if (merged_attributes[:with] or merged_attributes[:without])
        validates_with PhonyPlausibleValidator, merged_attributes.clone
      end

    end
  end
end
