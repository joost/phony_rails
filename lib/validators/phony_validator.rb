# Uses the Phony.plausible method to validate an attribute.
# Usage:
#   validate :phone_number, :phony_plausible => true
class PhonyPlausibleValidator < ActiveModel::EachValidator

  # Validates a String using Phony.plausible? method.
  def validate_each(record, attribute, value)
    return if value.blank?
    record.errors[attribute] << (options[:message] || "is an invalid number") if not Phony.plausible?(value)
  end

end

module ActiveModel
  module Validations
    module HelperMethods

      def validates_plausible_phone(*attr_names)
        validates_with PhonyPlausibleValidator, _merge_attributes(attr_names)
      end

    end
  end
end
